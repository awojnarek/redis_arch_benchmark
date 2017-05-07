#!/usr/bin/env ruby
require 'pp'
#############
# Varibales #
#############

Architecture = %x[uname -i].strip
Date         = %x[date +"%m%d%y_%H%M%S"].strip
Output_File  = "#{Date}_run.csv"

SMT          = [ "2", "4", "8" ] 
#Num_Reqs     = [ "1000", "10000", "100000", "1000000" ]
#Num_Clients  = [ "50", "100", "200", "500" ]

Num_Reqs     = [ "1000", "10000" ]
Num_Clients  = [ "50", "100" ]

#############
# Functions #
#############
def activate_smt(smt)
  begin

    %x[ppc64_cpu --smt=#{smt}]

  rescue => msg 
    printf "error in activate_smt => #{msg}\n"
    exit 1
  end
end

def benchmark_redis(requests,clients,*smt)
  begin

    if ! smt.nil?
      smt = smt.join("")
      activate_smt(smt)
    end
 
    results = Hash.new { |h,k| h[k] = {} }
    result = %x[redis-benchmark -c #{clients} -n #{requests}]

    result = result.split(/\n======/)
    result.each do |e|
      dataset = e.split("\n")
      category = dataset.grep(/======/).join(" ").split(" ")[0].gsub(/:/, '')
      rq_p_sec = dataset.grep(/requests per second/).join(" ").split(" ")[0]
      rq_compl = dataset.grep(/completed in/).join(" ").split(" ")[4]
      results[category]["requests per second"] = rq_p_sec
      results[category]["requests completed in"] = rq_compl
    end

    return results

  rescue => msg
    printf "Error in benchmark_redis => #{msg}\n"
    exit 1
  end
end

########
# Main #
########

# Checks
if %x[which redis-benchmark 2>/dev/null].strip == ""
  printf "redis-benchmark does not exist; quitting\n"
  exit 1
end

if Architecture == "ppc64le"

  # Run tests for Power Linux"
  printf "*Running benchmarks for Power Linux*\n"
  printf "architecture,smt,requests,clients,category,requests per second,requests completed in\n"

  # Get the number combination of requests and clients
  req_clients_combo = Num_Reqs.product(Num_Clients)

  # Loop through each SMT 
  SMT.each do |smt|
    
    req_clients_combo.each do |e|
      requests = e[0]
      clients  = e[1]

      result = benchmark_redis(requests,clients,smt)
      result.each do |x|
        category = x[0]
        hash     = x[1]
        rq_p_sec = hash["requests per second"]
        rq_compl = hash["requests completed in"]
        printf "ppc64le,#{smt},#{requests},#{clients},#{category},#{rq_p_sec},#{rq_compl}\n"
      end
    end
  end
  
elsif Architecture == "x86_64"
  
  # Run tests for X86
  printf "Running benchmarks for x86_64 Linux\n"

  # Get the number combination of requests and clients
  req_clients_combo = Num_Reqs.product(Num_Clients)

end

