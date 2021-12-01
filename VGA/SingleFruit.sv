//handles the printing of a single fruit
module	SingleFruit	(	
					input		logic	clk,
					input		logic	resetN,
					input 	logic signed	[10:0] pixelX,// current VGA pixel 
					input 	logic signed	[10:0] pixelY,
					input 	logic signed	[10:0] topLeftX, //position on the screen 
					input 	logic	signed   [10:0] topLeftY,   // can be negative , if the object is partliy outside 
					input		int	fruitChoice,
					input		logic drawFruit,
					
					output	logic	drawingRequest, // indicates pixel inside the bracket
					output	logic	[7:0]	 RGBout //optional color output for mux 
);


wire [10:0] offsetX;
wire [10:0] offsetY;
wire fruitRequest;



square_object  //creating a new instance of square object
	u0 (.clk(clk) , .resetN(resetN), .pixelX(pixelX), .pixelY(pixelY), .topLeftX(topLeftX), .topLeftY(topLeftY),//inputs
		 .offsetX(offsetX), .offsetY(offsetY), .drawingRequest(fruitRequest)); //outputs

FruitBitMap u1 (.clk(clk), .resetN(resetN), .offsetX(offsetX), .offsetY(offsetY), .InsideRectangle(fruitRequest)
, .fruitChoice(fruitChoice), .drawFruit(drawFruit), .drawingRequest(drawingRequest), .RGBout(RGBout));

endmodule 