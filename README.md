# Overview
You can run this script on an X86 or Power Linux box to get csv data back about performance. This script takes into account hyperthreading etc - and different characteristics such as requests per second, number of clients etc.


# Data Output
architecture,smt,requests,clients,category,requests per second,requests completed in
ppc64le,2,1000,50,PING_INLINE,83333.34,0.01
ppc64le,2,1000,50,PING_BULK,83333.34,0.01
ppc64le,2,1000,50,SET,83333.34,0.01
ppc64le,2,1000,50,GET,83333.34,0.01
...
