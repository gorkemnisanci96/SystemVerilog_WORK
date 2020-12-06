
//====================================
//       ASSERTIONS EXAMPLE 1 
//====================================

module asrt_ex1();
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
endmodule :asrt_ex1



//====================================
//       ASSERTIONS EXAMPLE 2
//===================================



