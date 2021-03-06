
// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018

//-- Eyal Lev 31 Jan 2021

module	objects_mux	(	
//		--------	Clock Input	 	
					input		logic	clk,
					input		logic	resetN,
		   // smiley 
					input		logic	smileyDrawingRequest, // two set of inputs per unit
					input		logic	[7:0] smileyRGB, 
					     
		  // add the box here 
					input    logic boxDrawingRequest,
					input 	logic [7:0] boxRGB,
			  
		  ////////////////////////
		  // background 
					input    logic HartDrawingRequest, // box of numbers
					input		logic	[7:0] hartRGB,   
					input		logic	[7:0] backGroundRGB, 
					
		  // fruit
					input		logic [4:0] fruitDrawingRequest,
					input		logic [4:0][7:0] fruitRGB,
			  
				   output	logic	[7:0] RGBOut
);
const int NUM_OF_FRUITS = 5;

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut	<= 8'b0;
	end
	
	else begin
		if (smileyDrawingRequest == 1'b1 )   
			RGBOut <= smileyRGB;  //first priority 
		 
		 
		 // add logic for box here 
		 
		 else if (boxDrawingRequest == 1'b1  )
			RGBOut <= boxRGB;
				else if (fruitDrawingRequest>0) begin //if trying to print at least 1 fruit
					for (int i=0;i<NUM_OF_FRUITS;i=i+1) begin
						if (fruitDrawingRequest[i] == 1)
							RGBOut <= fruitRGB[i];
					end
				end
				else if (HartDrawingRequest == 1'b1)
						RGBOut <= hartRGB;
						else 
							RGBOut <= backGroundRGB ; // last priority 
		end ; 
	end

endmodule


