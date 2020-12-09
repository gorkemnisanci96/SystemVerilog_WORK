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
$stop;
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
//  b-Type Parameters
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


// Type Parameters 

endmodule: example4




















