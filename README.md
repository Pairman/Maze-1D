# Maze-1D
One dimensional rendered, 8x8 maze game on a ZYPI (ZYNQ 7020) board. 

## I/O
### Inputs
- ```sys_clk```, ```sys_rst```.
- ```BTNC0```: Game reset. High active.
- ```BTNU0```, ```BTND0```, ```BTNL0```, ```BTNR0```: Player movement controls. High active.
- ```MAPL0```, ```MAPR0```: Map row controls. High active.
### Outputs
- ```LED[7:0]```: LEDs. High active.
- ```SEGS[6:0]```: Common cathode 7-segment display.
<img src="https://github.com/user-attachments/assets/d0ef8d3a-1458-4b6f-a189-0ade6e9f0e18" alt="schema-led-segments" width="25%"/>

## Gamerule
- Maze map is defined in ```maze_data.mem```. Maze entrance is (0, 0) and exit is (7, 7).
- Player can move in four directions with ```BTN*0```.
- Player and maze row will be displayed on the ```LED```, with bright/dim dots representing the player/walls.
- The currently displayed row can be switched with ```MAP*0```, with its index displayed on the ```SEGS```. Only one row at a time, not necessarily the row where the player is.
- Player wins reaching (7, 7). ```SEGS``` will flash on winning.
