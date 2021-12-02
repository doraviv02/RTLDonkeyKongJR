module	Fruit(	
 
					input	logic	clk,
					input	logic	resetN,
					input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
					input logic [4:0] monkeyCollision, //checks collisions with every single fruit
					input logic [10:0] random_X, //random X placement given as an input

					output	 logic signed 	[4:0][10:0]	topLeftX, // output the top left corner 
					output	 logic signed	[4:0][10:0]	topLeftY,  // can be negative , if the object is partliy outside
					output 	 logic [4:0] drawFruit, //decides on whether we have to draw the fruit or not
					output 	 int fruitChoice[4:0]
);

const int	x_FRAME_SIZE	=	639;
const int	y_FRAME_SIZE	=	479;
const int	bracketOffset =	30;
const int   FRUIT_WIDTH = 32;
const int   FRUIT_HEIGHT = 32;

const int   NUM_OF_FRUITS = 5;
const logic[10:0]   Y_PLACEMENTS[4:0] = '{160,200,240,280,320};

parameter int choiceOrder[4:0] = '{0,1,2,3,4}; //for each fruit we decide which 

logic randomDelay;
int Unfixed_X = 5;
logic [10:0] X_PLACEMENTS[4:0];
logic [4:0] eaten;

//////////--------------------------------------------------------------------------------------------------------------=
//  checks collision

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin
		eaten <= '{default:0};
		X_PLACEMENTS <= '{default:0};
		Unfixed_X <= 5;
	end
	else begin
		//setting the random X location of fruits. random rises as well in start of frame so we need a delay of 1 clk
		if (randomDelay) begin
			randomDelay <=0;
			Unfixed_X<= Unfixed_X-1;
					X_PLACEMENTS[Unfixed_X-1]<= random_X;
					eaten[Unfixed_X-1] <= 0;
		end
		if (startOfFrame) begin
			if (Unfixed_X>0) //if we havent fixed X location we set it in the first 5 frames.
				randomDelay <= 1;
			else begin
				for (int i=0; i<NUM_OF_FRUITS; i= i+1) begin
					topLeftX[i] <= X_PLACEMENTS[i];
					topLeftY[i] <= Y_PLACEMENTS[i];
					drawFruit[i] <= !eaten[i];
				end
			end
		end
		
		for (int i=0;i<NUM_OF_FRUITS; i = i+1) begin
			if (monkeyCollision[i] == 1)
				eaten[i] <= 1;
		end
		
	end
end

assign fruitChoice = choiceOrder;

endmodule