require 'spec_helper'
include Game2048

describe '2048 Rules' do
  let(:win_board) { Board.new([[2048, 0, 0, 0], 
                               [   0, 0, 0, 0], 
                               [   0, 0, 0, 0], 
                               [   0, 0, 0, 0]])}

  describe Board do
    let(:board) { Board.new }
    let(:in_game_board) { Board.new([[0, 0, 0, 0], 
                                     [0, 4, 0, 0], 
                                     [0, 4, 4, 0], 
                                     [0, 0, 0, 0]]) }
    
    let(:end_board) { Board.new([[ 2,   4,   8,  16], 
                                 [ 4,   8,  16,  32], 
                                 [ 8,  16,  32,  64], 
                                 [16, 256,  64, 128]]) }
    

    it "should have four rows" do
      expect(end_board.rows).to eq([Row.new( 2,   4,   8,  16), 
                                    Row.new( 4,   8,  16,  32), 
                                    Row.new( 8,  16,  32,  64), 
                                    Row.new(16, 256,  64, 128)])
    end

    it "should have four columns" do
      expect(end_board.columns).to eq([Column.new( 2,  4,  8,  16), 
                                       Column.new( 4,  8, 16, 256), 
                                       Column.new( 8, 16, 32,  64), 
                                       Column.new(16, 32, 64, 128)])
    end

    it "connects the rows and columns into a grid" do
      expect(end_board.columns[2][3]).to be(end_board.rows[3][2])
    end

    describe '#lose?' do
      it "returns true if the game has no valid moves" do
        expect(end_board.lose?).to be true
      end

      it "returns false if there's moves left" do
        expect(in_game_board.lose?).to be false
      end
    end

    describe '#win?' do
      it "returns true if there's a 2048 tile" do
        expect(win_board.win?).to be true
      end

      it "returns false if there's no 2048 tile" do
        expect(in_game_board.win?).to be false
      end
    end

    describe '#up' do
      it "applies the pull rule to each column" do
        expect(in_game_board.up).to eq(Board.new([[0, 8, 4, 0], 
                                                  [0, 0, 0, 0], 
                                                  [0, 0, 0, 0], 
                                                  [0, 0, 0, 0]]))
      end
    end

    describe '#down' do
      it "applies the push rule to each column" do
        expect(in_game_board.down).to eq(Board.new([[0, 0, 0, 0], 
                                                    [0, 0, 0, 0], 
                                                    [0, 0, 0, 0], 
                                                    [0, 8, 4, 0]]))
      end
    end

    describe '#left' do
      it "applies the pull rule to each row" do
        expect(in_game_board.left).to eq(Board.new([[0, 0, 0, 0], 
                                                    [4, 0, 0, 0], 
                                                    [8, 0, 0, 0], 
                                                    [0, 0, 0, 0]]))
      end
    end

    describe '#right' do
      it "applies the push rule to each row" do
        expect(in_game_board.right).to eq(Board.new([[0, 0, 0, 0], 
                                                     [0, 0, 0, 4], 
                                                     [0, 0, 0, 8], 
                                                     [0, 0, 0, 0]]))
      end
    end

    describe ".create" do
      it "creates an empty board with two random values" do
        expect_any_instance_of(Board).to receive(:add_value).twice
        Board.create
      end
    end
  end

  describe Loop do
    it "ends the game if there's a win condition" do
      expect(Loop.new(win_board).start).to eq(:win)
    end

    it "ends the game if there's a lose condition" do
      win_board = Board.new([[128, 64, 32, 16], [64, 32, 16, 8], [32, 16, 8, 4], [16, 8, 4, 2]])
      expect(Loop.new(win_board).start).to eq(:lose)
    end

    context "no win or lose" do
      it "ends the game with a quit condition if a quit command is entered" do
        expect(Loop.new(Board.create).input(:quit)).to eq(:quit)
      end
      context "quit command hasn't been entered" do
        it "applies the movement to the board if a movement command is entered" do
          board = Board.create
          lewp = Loop.new(board)
          expect(board).to receive(:up)
          lewp.input(:up)
        end

        it "adds two new values to the board in random locations" do
          board = Board.create
          lewp = Loop.new(board)
          expect(board).to receive(:add_value)
          lewp.input(:up)
        end
      end
    end
  end

  describe Line do
    it "should have four values" do
      expect(Line.new.values.size).to be(4)
      expect{Line.new(4, 4)}.to raise_error
    end

    it "only accept powers of two" do
      expect{Line.new(3, 2, 2, 2)}.to raise_error
    end

    describe "#push" do
      it "does not reverse the line before applying the rule" do
        expect(Line.new(0, 4, 2, 0).push).to eq(Line.new(0, 0, 4, 2))
      end
    end

    describe '#pull' do
      it "reverses the line before applying the data" do
        expect(Line.new(0, 4, 2, 0).pull).to eq(Line.new(4, 2, 0, 0))
      end
    end
  end

  describe Rule do
    describe '#apply' do
      it "dries and shifts zeroes onto the line" do
        expect(Rule.new(Line.new(0, 4, 0, 2)).apply).to eq([0, 0, 4, 2])
      end

      context "the last two values are the same" do
        context "the first two values are the same" do
          it "combines the last and first pairs" do
            expect(Rule.new(Line.new(2, 2, 4, 4)).apply).to eq([0, 0, 4, 8])
          end

          it "does not combine four of the same number into one" do
            expect(Rule.new(Line.new(4, 4, 4, 4)).apply).to eq([0, 0, 8, 8])
          end
        end

        context "the first two values are different" do
          it "dries and shifts zeroes onto the line" do
            expect(Rule.new(Line.new(2, 8, 4, 4)).apply).to eq([0, 2, 8, 8])
          end

          it "only combines two if three numbers are the same" do
            expect(Rule.new(Line.new(2, 4, 4, 4)).apply).to eq([0, 2, 4, 8])
          end
        end
      end

      context "the last two values are different" do
        context "the middle two values are the same" do
          it "combines the two values into the third position" do
            expect(Rule.new(Line.new(2, 4, 4, 2)).apply).to eq([0, 2, 8, 2])
          end
        end

        context "the middle two values are different" do
          context "the first two values are the same" do
            it "combines the two values into the second position" do
              expect(Rule.new(Line.new(4, 4, 8, 2)).apply).to eq([0, 8, 8, 2])
            end
          end

          context "the first two values are different" do
            it "does nothing" do
              expect(Rule.new(Line.new(2, 4, 8, 16)).apply).to eq([2, 4, 8, 16])
            end
          end
        end
      end
    end
  end
end