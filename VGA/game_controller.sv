
// game controller dudy Febriary 2020
// (c) Technion IIT, Department of Electrical Engineering 2021 
//updated --Eyal Lev 2021


module	game_controller	(	
			input	logic	clk,
			input	logic	resetN,
			input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
			input	logic	drawing_request_Ball,
			input	logic	drawing_request_1,
			input logic [4:0] drawing_request_Fruit,
			input logic drawing_request_Rope,
			
			output logic wallCollision, // active in case of collision between two objects
			output logic ropeCollision, // active in case of collision between monkey and rope
			output logic [4:0] fruitCollision //active in case of collision between monkey and fruit
);

// drawing_request_Ball   -->  smiley
// drawing_request_1      -->  brackets
// drawing_request_2      -->  number/box 

assign fruitCollision = drawing_request_Ball? drawing_request_Fruit:0;

assign wallCollision = (drawing_request_Ball &&  drawing_request_1);// collision between monkey and walls
assign ropeCollision = (drawing_request_Ball &&  drawing_request_Rope); // collision with monkey and rope


logic flag ; // a semaphore to set the output only once per frame / regardless of the number of collisions 

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
		flag	<= 1'b0;
	end 
	else begin 
			if(startOfFrame) 
				flag = 1'b0 ; // reset for next time 
				

if ( wallCollision  && (flag == 1'b0)) begin 
			flag	<= 1'b1; // to enter only once 
		end
	end 
end

endmodule
