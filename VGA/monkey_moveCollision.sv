
// Monkey Moving and Collision


module	monkey_moveCollision	(	
 
					input	logic	clk,
					input	logic	resetN,
					input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
					
					input logic jumpIsPressed,
					
					input logic digitIsPressed,
					input logic [3:0] digit,
					
					input logic wallCollision,  //collision if monkey hits a wall					
					input logic ladderCollision, //collision with ladder, which behaves a different way
					
					input	logic	[3:0] HitEdgeCode, //one bit per edge 


					output    logic signed 	[10:0]	topLeftX, // output the top left corner 
					output	 logic signed	[10:0]	topLeftY  // can be negative , if the object is partliy outside 
					
);


// a module used to generate the  ball trajectory.  

parameter int INITIAL_X = 280;
parameter int INITIAL_Y = 185;
parameter int INITIAL_X_SPEED = 40;
parameter int INITIAL_JUMP_SPEED = -500; //absolute value of jump speed
parameter int MAX_Y_SPEED = 230;
const int INITIAL_Y_ACCEL=5;

const int	FIXED_POINT_MULTIPLIER	=	64;
// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that 
// we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
// we divide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions
const int	x_FRAME_SIZE	=	639 * FIXED_POINT_MULTIPLIER; // note it must be 2^n 
const int	y_FRAME_SIZE	=	479 * FIXED_POINT_MULTIPLIER;
const int	bracketOffset =	30;
const int   OBJECT_WIDTH_X = 64;
const int   HEIGHT_OF_EDGE = 8;
int Xspeed, topLeftX_FixedPoint; // local parameters 
int Yspeed, topLeftY_FixedPoint;
int  Y_ACCEL = 5;

logic xflag;
logic yflag;
logic jumpFlag;
logic onRope;

// Moving left or right
always_ff@(posedge clk or negedge resetN)
begin
	if (!resetN) begin
	end
	else begin
		//collision executes once a frame
		//we have to counteract it in order to be able to change monkey's speed to stay off walls.
		if (startOfFrame) xflag=1'b0;
	
		if (wallCollision && (HitEdgeCode==4'b1000||HitEdgeCode==4'b0010)) begin //only side collided with wall
			xflag=1'b1;
			if (HitEdgeCode[3])//collision left wall
					Xspeed <= INITIAL_X_SPEED;
				else if (HitEdgeCode[1]) //collision right wall
					Xspeed <= INITIAL_X_SPEED*-1;
		end
	
		else if (xflag==1'b0) begin
			if (digitIsPressed) begin
				if(digit==4) //pressing right
					Xspeed <= INITIAL_X_SPEED*-1;
				if (digit==6)//pressing left
					Xspeed <= INITIAL_X_SPEED;
			end
			else Xspeed<=0;
		end
	end
end


//Handles moving up/down and jumping
always_ff@(posedge clk or negedge resetN)
begin
	if (!resetN) begin
		topLeftY_FixedPoint <= INITIAL_Y *FIXED_POINT_MULTIPLIER;
	end
	else begin
	
		if (jumpIsPressed)//Pressed the jump key
			jumpFlag <=1;
			
		if (ladderCollision||(wallCollision && (HitEdgeCode==4'b0001||HitEdgeCode==4'b1111))) //collided with floor or rope
		begin
			yflag <= 1;
			Y_ACCEL <= 0;
			if (!ladderCollision) begin
				Yspeed <= (HitEdgeCode==4'b1111)?-HEIGHT_OF_EDGE:0; //if the monkey moved down too much and is "inside" wall, push him slightly up
			end
			else begin //we are on the rope
				onRope <=1;
				if (digitIsPressed) begin
					if (digit==2) //pressing down
						Yspeed <= 60;
					else if (digit==8) //pressing up
						Yspeed <= -60;
				end
				else Yspeed <=0;
			end
		end
	
		if (!yflag) begin //if we haven't hit the floor
			Y_ACCEL<= INITIAL_Y_ACCEL;
			
			if(wallCollision && HitEdgeCode == 4'b0100)
				Yspeed <= 10; //Hit top edge, 10 speed is just so the monkey can start falling
		end
		
		else begin //touched the floor this frame
			if (jumpFlag && !onRope) begin//On the floor and pressed the jump key this frame
				Yspeed <= INITIAL_JUMP_SPEED;
				Y_ACCEL<= INITIAL_Y_ACCEL;
			end
		end
	
		if (startOfFrame == 1'b1) begin
			topLeftY_FixedPoint <= topLeftY_FixedPoint + Yspeed; //Change is done here because it glitched out sometimes
			if (Yspeed < MAX_Y_SPEED) //  limit the speed while going down 
				Yspeed <= Yspeed + Y_ACCEL; // deAccelerate : slow the speed down every clock tic
			yflag <= 0;
			jumpFlag <=0;
			onRope <= 0;
		end
		
	end
end


//////////--------------------------------------------------------------------------------------------------------------=
//  calculation of X Axis speed using and position calculate regarding X_direction key or colision

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin
		//Xspeed	<= INITIAL_X_SPEED;
		topLeftX_FixedPoint	<= INITIAL_X * FIXED_POINT_MULTIPLIER;
	end
	else begin
		   
			
		if (startOfFrame == 1'b1 )//&& Yspeed != 0) 
		begin
			topLeftX_FixedPoint <= topLeftX_FixedPoint + Xspeed;
		end
					
	end
end

//get a better (64 times) resolution using integer   
assign 	topLeftX = topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
assign 	topLeftY = topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER ;    


endmodule
