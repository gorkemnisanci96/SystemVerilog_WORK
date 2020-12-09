`timescale 1ns / 1ps




module example1();

//1-SystemVerilog rand Variables 
// When we decleare a rand type and call a randomize function,
// randomize function assign random numbers to the variable "data".
// Random values are assigned to variables based on their length
//For examples, a 8-bit data will get random values between 0 and 255 with
//1/256 probability

// Class Decleration with rand data type 
class Packet;
    rand bit [2:0] data;
endclass  

Packet pkt = new();

initial begin

    for (int i=0; i < 10 ; i++)begin
        pkt.randomize();
        $display("RAND itr=%0d data=0x%0h",i,pkt.data);
    end 
    
end 
// 2- System Verilog randc(random-cyclic) Variables 
// This datatype cycles through all the values within 
// their range before repeating any particular value.
// When a number is repeated, it make sure that all the numbers are assigned before
class Packet2;
randc bit [2:0] data;
endclass 


Packet2 pkt2= new();

initial begin 
    for (int i=0;i<10; i++)begin
        pkt2.randomize();
        $display("RANDC itr=%0d data=0x%0h",i,pkt2.data);
    end 
end 


endmodule :example1




module example2();

typedef struct {
  rand bit [10:0] ID;      // 11-bit identifier
  rand bit        RTR;     // reply required?
       bit  [1:0] rsvd;    // "reserved for expansion" bits
  rand bit  [3:0] DLC;     // 4-bit Data Length Code
  rand byte       data[];  // data payload
       bit [14:0] CRC;     // 15-bit checksum
} message_t;







endmodule :example2










