Hi, this is my aborted attempt to build an AI engine for 2048. I got as far as making the game engine work. There is a very basic AI engine that basically just goes down and right until it can't, then it swipes left.

Run the game with keyboard controls: `ruby 2048.rb`

Run the game with AI input: `ruby 2048.rb ai`

Run the game 10 times with AI input, benchmarking how many moves the game lasted: `ruby 2048 aibench`

Tested on Ruby 2.3 and 2.4