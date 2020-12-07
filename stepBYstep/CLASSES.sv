`timescale 1ns / 1ps
// System Verilog CLASSSES examples 



module classes_ex1 ();
// Classes 

// A Class decleration 
class my_class;
// decleare a integer variable 
  int number;
  
  // The task is used to set the variable 
  task set (input int i);
    number = i;
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

object_1.set(3);
$display("object_1.x is %d", object_1.get());
$stop;
end 





endmodule :classes_ex1

