#computer networks assignment-1
#devanshi gariba- 131010
# UDP: 1 ----> 10
# FTP: 2 ----> 7
# UDP: 8 ----> 0

#Lan simulation
set ns [new Simulator]

#determination of colors for data flows with their fid's
$ns color 1 Blue
$ns color 2 green
$ns color 3 pink

#opening all the tracefiles
set tracefile1 [open out.tr w]
set winfile [open winfile w]
$ns trace-all $tracefile1
#opening all the nam fileS
set namfile [open out.nam w]
$ns namtrace-all $namfile
#defining the finish procedure
proc finish {} { \
global ns tracefile1 namfile
$ns flush-trace
close $tracefile1
close $namfile
exec nam out.nam &
exit 0
} 

#creating all the eleven nodes (0-10)
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]
set n9 [$ns node]
set n10 [$ns node]

# defining colours of all the nodes
$n0 color Blue
$n1 color red
$n2 color green
$n3 color Blue
$n4 color Blue
$n5 color Blue
$n6 color Blue
$n7 color Blue
$n8 color red
$n9 color Blue
$n10 color Blue


#create links between the nodes
$ns duplex-link $n0 $n3 2Mb 10ms DropTail
$ns duplex-link $n0 $n1 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link $n2 $n3 2Mb 10ms DropTail
set lan [$ns newLan "$n2 $n4 $n9" 0.5Mb 40ms LL Queue/DropTail MAC/Csma/Cd Channel]
$ns duplex-link $n4 $n5 2Mb 10ms DropTail
$ns duplex-link $n5 $n6 2Mb 10ms DropTail
$ns duplex-link $n4 $n6 2Mb 10ms DropTail
$ns duplex-link $n6 $n7 2Mb 10ms DropTail
$ns duplex-link $n6 $n8 2Mb 10ms DropTail
$ns duplex-link $n9 $n10 2Mb 10ms DropTail


#orientation of all the node positions
$ns duplex-link-op $n0 $n3 orient right
$ns duplex-link-op $n0 $n1 orient down
$ns duplex-link-op $n1 $n2 orient right
$ns duplex-link-op $n2 $n3 orient up
$ns duplex-link-op $n4 $n5 orient right-up	
$ns duplex-link-op $n5 $n6 orient down
$ns duplex-link-op $n4 $n6 orient right-down
$ns duplex-link-op $n6 $n7 orient left-down
$ns duplex-link-op $n6 $n8 orient right-down
$ns duplex-link-op $n9 $n10 orient right




$ns queue-limit $n2 $n3 20

#setup of TCP connection 
# FTP connection from node 2 to node 7
set tcp [new Agent/TCP/Newreno]
$ns attach-agent $n2 $tcp
set sink [new Agent/TCPSink/DelAck]
$ns attach-agent $n7 $sink
$ns connect $tcp $sink
$tcp set fid_ 1    # colour id
$tcp set packet_size_ 1000  #size of each packet

#set FTP over TCP connection
set ftp [new Application/FTP]
$ftp attach-agent $tcp

#setup Of  2UDP connections 
# 1st udp connection from node 1 to node 10
set udp [new Agent/UDP]
$ns attach-agent $n1 $udp
set null [new Agent/Null]
$ns attach-agent $n10 $null
$ns connect $udp $null
$udp set fid_ 2
# 2nd udp connection from node 8 to node 0
set udp1 [new Agent/UDP]
$ns attach-agent $n8 $udp1
set null1 [new Agent/Null]
$ns attach-agent $n0 $null1
$ns connect $udp1 $null1

$udp1 set fid_ 3

#setup a CBR over UDP connection
# cbr1
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 0.01Mb
$cbr set random_ false
# cbr2
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$cbr1 set type_ CBR
$cbr1 set packet_size_ 1000
$cbr1 set rate_ 0.01Mb
$cbr1 set random_ false

#scheduling the events at different time slots
$ns at 0.1 "$cbr start"
$ns at 0.5 "$ftp start"
$ns at 0.5 "$cbr1 start"
$ns at 120.0 "$ftp stop"
$ns at 122.5 "$cbr stop"
$ns at 122.5 "$cbr1 stop"

proc plotWindow {tcpSource file} {
global ns
set time 0.1
set now [$ns now]
set cwnd [$tcpSource set cwnd_]
puts $file "$now $cwnd"
 $ns at [expr $now+$time] "plotWindow $tcpSource $file"
}


$ns at 0.1 "plotWindow $tcp $winfile"
$ns at 122.0 "finish"
$ns run
