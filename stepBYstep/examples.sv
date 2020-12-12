`timescale 1ns / 1ps

//===============================================================
//                        Example 1                  
//===============================================================


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


//===============================================================
//                        Example 2                  
//===============================================================

module example2();
// Classes 

// A Class decleration 
class my_class;
// decleare a integer variable 
  int number;
  local int number2;
  
  // The task is used to set the variable 
  task set (input int i);
    number = i;
    number2 = number +5;
  endtask :set 
  
  // The function returns the value of the number that is decleared in the class  
  function int get;
    return number;
  endfunction : get 
  
endclass

// This statement decleare object_1 to be my_class  
//and  create an object abd assigns its handle to object_1 ( What "new" does)
my_class object_1 = new;


initial begin

//1- Using setter to initialize a class member 
object_1.set(3);
$display("object_1.x is %d", object_1.get());

//2- You can also initialize values directly without a setter 
// By default class members are publicly available so we can access it as shown below 
object_1.number=23;
$display("The number: %d",object_1.number);

//3-If we define a class member like "local int number2", we can only access it by using class methods
// The below code is illegal because "ccess to local member 'number2' from outside a class context is illegal"
//object_1.number2=3;
// We ca use class methods to acces to the number2 
object_1.set(5);
end 


// 4- We can parameterized the classes, too . 

class Instruction #(parameter int imm_length=12);

bit [imm_length-1:0] imm;

endclass : Instruction 


//5-We can overwrite the default parameter value 
Instruction #(4) SLL;                // imm value is [4:0]
Instruction #(.imm_length(21)) JAL;  // imm value is [21:0] 
Instruction ADD;                     // imm value is [11:0]


//6- We can also pass a datatype to a class 

class pass_type #(parameter type T = int);
T data;
endclass 


pass_type pass_int;   // data is int 
pass_type #(bit [7:0]) pass_bit;  // data is bit [7:0]

//7-Extending Classes-Inheritance 
class Register; 
bit [6:0] data;
bit [2:0] CRC;
endclass

class ShiftRegister extends Register;

task shiftleft;  data = data<<1;  endtask
task shiftright; data = data>>1;  endtask 

endclass 


ShiftRegister reg1 = new;

initial begin
reg1.data=7'b111010;
$display("Before Shift reg1.data= %b",reg1.data);
#10;
reg1.shiftleft();
$display("After  Shift reg1.data= %b",reg1.data);
end 


//8- If we decleare a class member as "local", it will not be 
// visible to extended class. So instead, we need to decleare it as protected. 
// Protected member is not visible to outside, but visible in extended classes. 
class ex_class;
protected int data;
endclass

endmodule :example2



//===============================================================
//                        Example 3                 
//===============================================================



module example3();
initial $display("************** asrt_ex1 **************");

/////////////////////////////////////////
///// 1-Immediate Assertions 
////////////////////////////////////////
// Immediate assertions are like if statetament. The difference is that
// if statement does not assert that the expression is true. 
///////////////////////////////////////
// Local Declerations 
reg A;
reg B;
reg data;
reg correct_data;
reg I;

integer error_count;

initial begin 
// Initialize Values of A and B 
A=1;
B=1;
#(10);
B=0;
#(10);
$stop;
end 

always_comb begin : ImmediateAssertions
// Display mesage in both correct and wrong case
//  
a1: assert (A == B) $display ("A equals B"); else $error("A does not Equal to B");
// Display Only Error statement 
//
a2: assert (A == B) else $error("A does not Equal to B");


// There are three severity levels that can be defined in the case of error 
//*$fatal
//*$error(DEFAULT SEVERITY)
//*$warning 
ReadCheck: assert (data==correct_data) else $error("memory read error");
           
Igt10: assert (I>10) else $warning("I is less than or equal to 10"); 
 
fatalerror: assert  (A == B) else $fatal("The A MUST be equal to B");
           
 
 // A set of jobs can be defined to be done in the case of pass or fail.           
//
AeqB: assert (A == B)
      else begin error_count++; $error("A should be equal to B"); end 
      
end : ImmediateAssertions

/////////////////////////////////////////
///// 2-Concurrent Assertions
////////////////////////////////////////
// The behaviour of a design may be specified using statements similar to these:
// "The Read and Write signals should never be asserted together."
// Concurrent assertions are behaviour such as this. 
// These are statements that assert that specified properties must be true.
//
// Local Declerations 
reg read;
reg write;
reg clk;
// Clock Generation 
initial clk=1'b0;
always #(5)clk=~clk;

always @(posedge clk) begin :ConcurrentAssertions
//always_comb begin --> it does not work with combinational block 

// The statement asserts that (read && write ) is never true at any point during simulation.
// 
read_write_enb: assert property (!(read && write ));

end :ConcurrentAssertions
endmodule :example3



//===============================================================
//                        Example 4                  
//===============================================================
// Parameterized Classes
//  a-Value Parameters
module example4();

class Message1;

logic [7:0]  data;
logic [11:0] address;

endclass :Message1


class Message2 #(int ADDR_W=16, DATA_W =8);

logic [DATA_W-1:0] data;
logic [ADDR_W-1:0] address;

endclass: Message2 


// m1 and m0 have same types 
Message1 m0 =new;
Message1 m1 =new;

initial begin 
m0.data=8'b10101110;  // We initialize m0 object 
m1=m0;                // We copy the m0 object to  m1  
end 



// So we can use the same class but create objects with different data lengths 
// Therefore m1 and m2 become different types 
Message2 #(32,32) m2 = new; // or: #(.ADDR_W(32), .DATA_W(32))
Message2 #(16,16) m3 = new;



initial begin
m2.data=32'habc;
//m3=m2; This is illegal because m3 and m2 have different types 
end 

endmodule: example4


//===============================================================
//                        Example 5                  
//===============================================================
//Testbench Automation and Constraints
// * struct * class * rand type 
// * randomize() with constraints *dynamic array 
// * task * 
module example5();


typedef struct {
  rand bit [10:0] ID;      // 11-bit identifier
  rand bit        RTR;     // reply required?
       bit  [1:0] rsvd;    // "reserved for expansion" bits
  rand bit  [3:0] DLC;     // 4-bit Data Length Code
  rand byte       data[];  // data payload
       bit [14:0] CRC;     // 15-bit checksum
} message_t;


class CAN_Message;
  rand message_t message;

  // Constraints 
  // When we Call test_message[i].randomize(); , the variables of 
  // test_message[i] object get random values. This constraints force 
  // those rand variables to get values in a certain range. 
  // For example DLC is a 4bit number so it can get values from 0 to 15
  // bit the constraint below forces it to get values from 0 to 8. 
  constraint c1 { message.DLC inside {[0:8]}; }
  // The 'data' in the struct is a dybamic array that can hold elements of type byte
  // This constraint set the size of the array during execution.
  // For example if message.DLC get a random value of 7, data array is going to
  // hold 8 byte elements . 
  constraint c2 { message.data.size() == message.DLC; }


  // Class methods go here 
  
  task set_RTR (input bit new_value);
    // Set the RTR bit as requested
    message.RTR = new_value;
    if (message.RTR) begin
      // Messages with the RTR bit set should have no data.
      message.DLC = 0;
      clear_data();  // make the data list empty
    end
  endtask :set_RTR

  task clear_data;
    message.data.delete();
  endtask :clear_data
  
    task getbits(ref bit data_o, input int delay=1);
    bit [17:0] header;
    bit [14:0] tail;
    header = {message.ID,message.RTR,message.rsvd,message.DLC};
    tail = message.CRC;
    $display("tail=%0b",tail);
    //step through message and output each bit (from left to right)
    foreach(header[i]) #delay data_o = header[i];
    foreach(message.data[i,j]) #delay data_o = message.data[i][j];
    foreach(tail[i]) #delay data_o = tail[i];
  endtask :getbits 
  
  
  task print();
    $display("Message ID   :0x%h  ",message.ID);
    $display("Message RTR  :0x%h ",message.RTR);
    $display("Message rsvd :0x%h ",message.rsvd);
    $display("Message DLC  :0x%h ",message.DLC);
    $display("Message data :0x%h ",message.data);
    $display("Message CRC  :0x%h ",message.CRC);
  endtask:print
  
  
endclass: CAN_Message




// Class Definition has been completed. Now lets use it in a testbench 


  bit data_o;
  const int bit_interval = 1;
  CAN_Message test_message[10];
  int interval=10;

  initial
  message_gen: begin
    for (int i = 0; i < 10; i++) begin
      $display("time = %0t",$time);
      // Create the test_message[i]  object 
      test_message[i] = new;
      // Randomize the variables that has rand variable type in the CAN_Message class 
      test_message[i].randomize();
      // Call the print method , that prints all the variables in the struct 
      test_message[i].print();
      test_message[i].getbits(data_o,bit_interval);
      #bit_interval $display("time = %0t",$time);
    end
    $finish;
  end:message_gen  
  
endmodule :example5




//===============================================================
//                        Example 6                
//===============================================================
// System Verilog Interfaces 
//
//
//
module example6();

// Interface definition
interface Bus;
  logic [7:0] Addr, Data;
  logic RWn;
endinterface :Bus



// Using the interface
// Interfaces encapsulate connectivity 
module TestRAM;
  Bus TheBus();                   // Instance the interface
  logic [7:0] mem[0:7];             
  RAM TheRAM (.MemBus(TheBus));   // Connect it
  initial
  begin
    TheBus.RWn = 0;               // Drive and monitor the bus
    #5;
    TheBus.Addr = 0;
    #5;
    for (int I=0; I<7; I++)          begin
      TheBus.Addr = TheBus.Addr + 1;
      #5;
                                     end                       
    TheBus.RWn = 1;
    #5;
    TheBus.Data  =7'd13;
    TheBus.RWn = 0;
    #5;
  end
  
endmodule :TestRAM



module RAM (Bus MemBus);
  logic [7:0] mem[0:255];

  always @*
    if (MemBus.RWn)
      MemBus.Data = 7'd12;
    else
      mem[MemBus.Addr] = MemBus.Data;
endmodule : RAM







endmodule :example6

//===============================================================
//                        Example 7               
//===============================================================
// Interface Ports 
//







//Interface definition 
interface ClockedBus (input Clk);
  logic[7:0] Addr, Data;
  logic RWn;
endinterface :ClockedBus

// RAM2 Module definition 
module RAM2 (ClockedBus Bus);
  logic [7:0] mem[0:255];
  
  always @(posedge Bus.Clk)
    if (Bus.RWn)
      Bus.Data = mem[Bus.Addr];
    else
      mem[Bus.Addr] = Bus.Data;
endmodule :RAM2 


module example7();
// Using the interface
  reg Clock=1'b0;
    
    always #5 Clock=~Clock;
  // Instance the interface with an input, using named connection
  ClockedBus TheBus (.Clk(Clock));
  // We use the interface to encapsulate the connectivity here
  RAM2 TheRAM (.Bus(TheBus));

endmodule :example7





//===============================================================
//                        Example 8               
//===============================================================
//Parameterised Interface
//
//


interface Channel #(parameter N = 0)
    (input bit Clock, bit Ack, bit Sig);
  bit [N-1:0] Buff;
  initial begin
    for (int i = 0; i < N; i++)
      Buff[i] = 0;
        end
  always @ (posedge Clock)  begin      
   if(Ack == 1) Sig = Buff[N-1];
   else         Sig = 0;
     
                            end                                              
endinterface :Channel
  
  
module TX(Channel Ch);

assign Ch.Buff=7'd12;

endmodule :TX


module example8();
// Using the interface
  bit Clock, Ack, Sig;
  // Instance the interface. The parameter N is set to 7using named
  // connection while the ports are connected using implicit connection
  Channel #(.N(7)) TheCh (.*);
  TX TheTx (.Ch(TheCh));
endmodule :example8






