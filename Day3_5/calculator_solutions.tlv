\m4_TLV_version 1d: tl-x.org
\SV
   // This code can be found in: https://github.com/stevehoover/RISC-V_MYTH_Workshop
   
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/RISC-V_MYTH_Workshop/ecba3769fff373ef6b8f66b3347e8940c859792d/tlv_lib/calculator_shell_lib.tlv'])

\SV
   m4_makerchip_module   // (Expanded in Nav-TLV pane.)

\TLV
   |calc
      @0
         $reset = *reset;
      @1    
         //Valid based on every second cycle, for output/input val1 to match
         //As valid is based on every second cycle, there will be many references to
         //the 2nd previous value, as the 'last' value will be discarded due to invalid cycle timing
         
         $valid = $reset ? 1'b0 : //reset to 0
                  >>1$valid + 1'b1; //or use previous valid sign and add 1 (0+1 or 1+1=2 == valid)
         $reset_or_valid = $valid || $reset;
         
         //$val1 will be the second previous result of the output, for valid cycle
         //$val2 will have the lowest 4 bits to be randomized and bits 31-4 will be assigned to 0 by default
         
         $val1[31:0] = >>2$out;
         $val2[31:0] = $rand2[3:0];
         
      ?$reset_or_valid
         @1 //Calculator Operations
            $sum[31:0] = $val1 + $val2;
            $diff[31:0] = $val1 - $val2;
            $prod[31:0] = $val1 * $val2;
            $quot[31:0] = $val1 / $val2;
            
         @2 //MUX Selector for Calc operation. Expanded to 3 bit for MEM functions.
            $out[31:0] = $reset        ? 32'b0 : 
                         $op == 3'b000 ? $sum :
                         $op == 3'b001 ? $diff :
                         $op == 3'b010 ? $prod :
                         $op == 3'b011 ? $quot :
                         $op == 3'b100 ? >>2$mem : //recall/save feature
                         >>2$out; 
            
            //Memory functions for recall/save features
            $mem[31:0] = $reset ? 32'b0 :
                         $op[2:0] == 3'b101 ? $val1 : //if operation 5 is chosen, use (>>2$out)
                         >>2$mem; //otherwise recall
            
         
         
      // Macro instantiations for calculator visualization(disabled by default).
      // Uncomment to enable visualisation, and also,
      // NOTE: If visualization is enabled, $op must be defined to the proper width using the expression below.
      //       (Any signals other than $rand1, $rand2 that are not explicitly assigned will result in strange errors.)
      //       You can, however, safely use these specific random signals as described in the videos:
      //  o $rand1[3:0]
      //  o $rand2[3:0]
      //  o $op[x:0]
   
   m4+cal_viz(@3) // Arg: Pipeline stage represented by viz, should be atleast equal to last stage of CALCULATOR logic.

   
   // Assert these to end simulation (before Makerchip cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
   

\SV
   endmodule
