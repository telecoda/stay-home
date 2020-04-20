pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function _init()
 -- init consts
 left=1
 right=2
 up=3
 down=4
	
	down_frames={0,1,2,1}
 left_frames={3,4,5,4}
 up_frames={6,7,8,7}
 anim_frames={}
 anim_frames[left]=left_frames
 anim_frames[right]=left_frames
 anim_frames[down]=down_frames
 anim_frames[up]=up_frames
 
 maze_map_x=24
 food_dot_small=19
 food_dot_large=20
 food_dot_empty=21

	intro_text={}
	intro_timer=0

	title_level = {}
	title_level.init = init_title
	title_level.draw = draw_title
	title_level.update = update_title

	announce_level = {}
	announce_level.init = init_announce
	announce_level.draw = draw_announce
	announce_level.update = update_announce

	freedom_level = {}
	freedom_level.init = init_freedom
	freedom_level.draw = draw_freedom
	freedom_level.update = update_freedom

	friends_level = {}
	friends_level.init = init_friends
	friends_level.draw = draw_friends
	friends_level.update = update_friends

	gameover_level = {}
	gameover_level.init = init_gameover
	gameover_level.draw = draw_gameover
	gameover_level.update = update_gameover

	outside_level = {}
	outside_level.init = init_outside
	outside_level.draw = draw_outside
	outside_level.update = update_outside

 pacfood_level = {}
	pacfood_level.init = init_pacfood
	pacfood_level.draw = draw_pacfood
	pacfood_level.update = update_pacfood
	
	levels={}
	-- level ids
	title_id=1
	announce_id=2
	friends_id=3
	pacfood_id=4
	outside_id=5
	gameover_id=6
	freedom_id=7
	-- todo id's
	--book_shop_id=8
	--pac_food2_id=9
	--book_shop2_id=10
	--walk_shop_id=11
	--inside_shop_id=12
	--walk_home_id=13
	--clap_nhs_id=14
	--high_scores_id=15
	
	-- this should match last level in game
	last_level = pacfood_id

	levels[title_id]=title_level
	levels[announce_id]=announce_level
	levels[freedom_id]=freedom_level
	levels[friends_id]=friends_level
	levels[gameover_id]=gameover_level
	levels[outside_id]=outside_level
	levels[pacfood_id]=pacfood_level

 -- call start here to init stuff
 start_game()
	
	-- set real level_id
	set_level(title_id)
	
	-- set temp: level_id for testing	
	set_level(pacfood_id)
	debug_grid=false 
end

function _draw()
	draw_func()
end

function _update()
	update_func()
end

function can_move(gopher,x_offset,y_offset)
	-- returns 2 bools
	-- first bool can move
	-- second bool has food
 maze_x, maze_y = get_map_loc(gopher.x+x_offset,gopher.y+y_offset)
 maze_x = maze_x + maze_map_x

 cell = mget(maze_x,maze_y)
	if cell==food_dot_small or cell == food_dot_large or cell == food_dot_empty then
		if gopher.kid and cell != food_dot_empty then
			--eat_food(maze_x,maze_y)
			return true,true
		end 
		return true,false
	end
	return false,false
end

function eat_food(gopher,x_offset,y_offset)
 maze_x, maze_y = get_map_loc(gopher.x+x_offset,gopher.y+y_offset)
 maze_x = maze_x + maze_map_x

 cell = mget(maze_x,maze_y)
	if cell==food_dot_small or cell == food_dot_large then
		food = food -1
	 mset(maze_x,maze_y,food_dot_empty)
	end
end


function change_direction(gopher) 
	if gopher.kid then
		-- is the player in front of me?
		dist_x = abs(player.x-gopher.x)
		dist_y = abs(player.y-gopher.y)

		dist = sqrt((dist_x*dist_x)+(dist_y*dist_y))
	 if dist < 8 then
	 	gopher.direction=player.direction
	 end
	end

end

function check_answer()
	answer=choices[selected_answer]
	if answer == current_question.correct then
		score=score+1
		current_question_number=current_question_number+1
		if current_question_number>#questions then
			next_level()
		else
			init_question()
		end
	else
		-- wrong answer
		game_over()
	end
end

function draw_gameover()
 cls()
	print("game over",44,11,8)
	print("i'm sorry, your actions",16,21,7)
	print("have put others people's",14,31,7)
	print("lives at risk",34,41,7)
	print("please stay safe",30,61,10)
	print("and try again 😐",30,71,10)
	draw_hud()
end

function draw_freedom()
 cls()
	print("congratulations!",32,11,8)
	print("your actions",40,21,7)
	print("have saved people's lives",12,31,7)
	print("thank you 😐",38,61,10)
	draw_hud()
end


function draw_announce()
 cls()
	print("march 23, 2020",35,11,11)
	map(16,0,32,32,8,8)
	draw_intro_text()
end

function draw_friends()
 cls()
	print("isolation questions",25,11,11)
	
	print("question:",4,24,8)
	--text="\""+ + "\""
	print("`"..current_question.text.."?`",8,36,10)
	-- draw choices
	for i=1,#choices do
	 if i==selected_answer then
 	print("->",4,42+i*10,11)
 	print(choices[i],16,42+i*10,12)
	 else
 	print(choices[i],16,42+i*10,7)
	 end
	end
	
	-- draw controls
	print("use up/down to select",24,64+#choices*10,9)
	print("press `z` to enter",32,72+#choices*10,9)
	
	draw_hud()
end


function draw_gopher(gopher)
	palt(3,true)
 palt(0,false)
 pal(12,gopher.colour)
 anim_frame=anim_frames[gopher.direction][gopher.frame]
 spr(anim_frame,gopher.x,gopher.y,1,1,gopher.flip)
 -- revert palette swap
 pal(12,12)
end

function draw_hud()
 rectfill(0,110,128,128,6)
 rect(1,111,126,126,5)
	-- score
	print("score:"..score,4,113,7)
	-- days
	print("days:"..days,64,113,7)
	-- food
	food_colour=7
	if food<10 then
		food_colour=8
	end
	print(" food:"..food,4,120,food_colour)
	-- health
	health_colour=7
	if health<10 then
		health_colour=8
	end

	print("  ♥:"..health,64,120,health_colour)
 draw_intro_text() 

	if debug_grid then
		-- draw grid + coords
		for x=0,128,8 do
			line(x,0,x,128,7)
			line(0,x,128,x,7)
		end
		print("x:"..player.x.." y:"..player.y,2,2,8)
		map_x,map_y=get_map_loc(player.x,player.y)
		print("mx:"..map_x.." my:"..map_y,2,10,8)
		-- draw player pos
		cx = player.x+4
		cy = player.y+4
		line(cx-1,cy,cx+1,cy,8)
		line(cx,cy-1,cx,cy+1,8)
		dx = abs(player.x-kids[1].x)
		dy = abs(player.y-kids[1].y)
		print("dx:"..dx.." dy:"..dy,2,18,8)

	end
end

function draw_intro_text()
 if intro_timer > 0 then
 	-- draw intro text rect
		lines=#intro_text
		height=lines*6+10
		top=64-height/2
		bottom=64+height/2
  rectfill(4,top,124,bottom,12)
  rect(5,top+1,123,bottom-1,13)
		for i=1,#intro_text do
		 text_line=intro_text[i]
   x=(64-(#text_line/2)*4)		
 		print(text_line,x,top+i*6,7)
		end		
 	intro_timer = intro_timer-1
	end
end

function draw_outside()
 cls()
	palt(3,false)
	map(0,0,0,0,26,26)
	draw_gopher(player)
	draw_hud()
end

function draw_pacfood()
 cls()
	-- draw maze
	palt(3,false)
	map(maze_map_x,0,0,0,26,26)
	draw_gopher(player)
	-- draw kids
	for i=1,#kids do
		draw_gopher(kids[i])
	end
	draw_hud()
end

function draw_title()
	-- this is the title page for the game
	cls(0)
	print("welcome to",44,8,7)
	print("stay home",46,18,7)
	print("by @telecoda",40,28,7)
	print("a game about",40,48,10)
	print("social distancing",30,58,10)
	print("for ludum dare 46",30,78,7)
	print("press up to start",30,98,8)

	draw_gopher(player)
end

--function eat_food(maze_x,maze,y)
	--food = food -1
	--mset(maze_x,maze_y,food_dot_empty)
--end

function game_over()
	set_level(gameover_id)
	health=0
end

function get_map_loc(gopher_x,gopher_y)
	-- convert x,y to map x,y
	cx = gopher_x+4
	cy = gopher_y+4
	x=flr(cx/8)
	y=flr(cy/8)
	return x,y
end

function init_announce()
	intro_text = {"uk announces stay at home", "campaign to stop the", "coronavirus spreading"}
	intro_timer = 120
end

function init_gameover()
end

function init_freedom()
end

function init_friends()
	intro_text = {"answer some questions", "about social distancing", "do you know what to do?"}
	intro_timer = 120

	questions = {}

	question1 = {}
	question1.text="friends ask you to meet"
	question1.correct="you should say no!"
	question1.wrong1="sure!"
	question1.wrong2="ok"
	questions[1]=question1

	question2 = {}
	question2.text="mum asks you to pop round"
	question2.correct="you should say no!"
	question2.wrong1="no problem"
	question2.wrong2="i'll be round later"
	questions[2]=question2

	question3 = {}
	question3.text="can i buy some new makeup"
	question3.correct="you should say no!"
	question3.wrong1="let's shop!"
	question3.wrong2="i love a good bargain"
	questions[3]=question3

 correct_answers=0
 current_question_number=1
	total_questions=#questions
	init_question()
end

function init_outside()
end

function init_pacfood()
	intro_text = {"stop the kids", "from eating all the food", "like a reverse pacman"}
	intro_timer = 120
 player.x=60
 player.y=87
 kid_colours={8,14,9,11}
 max_kids=4
 kids={}
	for i=1,max_kids do
		kid=init_kid(40+(i%6)*8,24,kid_colours[(i%4)+1])
		kids[i]=kid
	end
end

function init_kid(x,y,colour)
	kid={}
	kid.x=x
	kid.y=y
	kid.colour=colour
	kid.flip=false
	kid.kid=true
	kid.direction=left
 kid.dir_count=0

	kid.frame=0
	kid.frame_count=1
	kid.frame_tick=2

	return kid
end

function init_question()

	current_question=questions[current_question_number]
 selected_answer=1
	choices={current_question.correct,current_question.wrong1,current_question.wrong2}
	--shuffle choices
	for i = #choices, 2, -1 do
		j = flr(rnd(i))+1
		choices[i], choices[j] = choices[j], choices[i]
	end
end

function init_title()
	player_init()
	draw_func=draw_title
	update_func=update_title
 player.x=30
 player.y=15
 player.frame_tick=10
end

function move_down(gopher)
 gopher.direction=down
 gopher.flip=false
 moved=false
	if can_move(gopher,0,3) then
		gopher.y = gopher.y +1
		moved=true
	end
	gopher=update_frame(gopher)
	return moved
end

function move_direction(kid)

	-- try to find a direction
	-- with food
	can_move_left,left_has_food = can_move(kid,-5,0)
	can_move_right,right_has_food = can_move(kid,3,0)
	can_move_up,up_has_food = can_move(kid,0,-5)
	can_move_down,down_has_food = can_move(kid,0,3)

	has_foods={}
	can_moves={}

	if left_has_food then
		add(has_foods,left)
	end
	if right_has_food then
		add(has_foods,right)
	end
	if up_has_food then
		add(has_foods,up)
	end
	if down_has_food then
		add(has_foods,down)
	end

	if can_move_left then
		add(can_moves,left)
	end
	if can_move_right then
		add(can_moves,right)
	end
	if can_move_up then
		add(can_moves,up)
	end
	if can_move_down then
		add(can_moves,down)
	end

	if #has_foods >0 then
		-- pick a random dir with food
		kid.direction=has_foods[flr(rnd(#has_foods))+1]		
		return true
	end

	if #can_moves >0 then
		-- pick a random dir
		kid.direction=can_moves[flr(rnd(#can_moves))+1]		
		return false
	end


end

function move_kid(kid)
 moved=false

	if kid.direction==left
 then
		eat_food(kid,-5,0)
		move_left(kid)
		return kid
	end
	if kid.direction==right then
 	eat_food(kid,3,0)
		move_right(kid)
		return kid
	end
	if kid.direction==up then
 	eat_food(kid,0,-5)
		move_up(kid)
		return kid
	end
	if kid.direction==down then
 	eat_food(kid,0,3)
		move_down(kid)
		return kid
	end

	return kid
end

function move_kids()
	for i=1,#kids do
		kid=kids[i]
		if kid.dir_count < 1 then
			move_direction(kid)
			kids[i]=move_kid(kid)
			kid.dir_count=10
		else
		 kid.dir_count=kid.dir_count-1
			kids[i]=move_kid(kid)
		end
		change_direction(kid)		
	end
end

function move_left(gopher)
 gopher.direction=left
 gopher.flip=true
 moved=false
	if can_move(gopher,-5,0) then
		gopher.x = gopher.x -1
		moved=true
	end
	gopher=update_frame(gopher)
	return moved
end

function move_right(gopher)
 gopher.direction=right
 gopher.flip=false
 moved=false
	if can_move(gopher,3,0) then
 	gopher.x = gopher.x +1
 	moved=true
	end
	gopher=update_frame(gopher)
	return moved
end

function move_up(gopher)
 gopher.direction=up
 gopher.flip=false
 moved=false
	if can_move(gopher,0,-5) then
		gopher.y = gopher.y -1
		moved=true
	end
	gopher=update_frame(gopher)
	return moved
end

function player_init()
 player = {}
 player.x=64
 player.y=64
 player.direction=down
 player.dir_count=0
 player.colour=12
 player.flip=false
	player.kid=false

	player.frame=0
	player.frame_count=1
	player.frame_tick=2
end

function next_level(id)
	current_level = current_level +1
	days = days +1
	if current_level > last_level then
		current_level = freedom_id
	end
	set_level(current_level)
end

function set_level(id)
	current_level=id
 cls()
	print("level:")
	print(id)
	level=levels[id]
	draw_func=level.draw
	update_func=level.update
	level.init()
end

function start_game()
 player_init()
 score=0
 food=86
 health=100
 days=0
	set_level(announce_id)
end

function update_announce()
	if (btnp()>0) then set_level(friends_id) end
end

function update_friends()
	if (btnp(2)) then
		-- up
		selected_answer = selected_answer-1
		if selected_answer==0 then
			selected_answer=#choices
		end
	end
	if (btnp(3)) then
		-- down
		selected_answer = selected_answer+1
		if selected_answer>#choices then
			selected_answer=1
		end
	end
	if (btnp(4)) then
		check_answer()
	end
end

function update_gameover()
	if (btnp()>0) then
		set_level(title_id)
	end
end

function update_frame(gopher)
	gopher.frame_count = gopher.frame_count+1
	if gopher.frame_count > gopher.frame_tick then
		gopher.frame_count=1
		gopher.frame = gopher.frame +1
		if gopher.frame > #down_frames then
			gopher.frame = 1
		end
	end
	return gopher
end

function update_freedom()
	if (btnp()>0) then
		set_level(title_id)
	end
end

function update_outside()
	if (btn(0)) then move_left(player) end
	if (btn(1)) then move_right(player) end
	if (btn(2)) then move_up(player) end
	if (btn(3)) then move_down(player) end
end

function update_pacfood()

	if intro_timer==0 then
		move_kids()
	end

	if (btn(0)) then move_left(player) end
	if (btn(1)) then move_right(player) end
	if (btn(2)) then move_up(player) end
	if (btn(3)) then move_down(player) end
end

function update_title()
 update_frame(player)
	if (btnp()>0) then start_game() end
end
__gfx__
333333333cc33cc333333333333333333333cc3333333333333333333cc33cc33333333300000000000000000000000000000000000000000000000000000000
3cc33cc3c77cc77c3cc33cc33333cc333cccc7733333cc333cc33cc3cccccccc3cc33cc300000000000000000000000000000000000000000000000000000000
c77cc77cc70cc07cc77cc77c3cccc773ccccc7033cccc773cccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000
c70cc07c3cf00fc3c70cc07cccccc703ccccccf0ccccc703cccccccc3cccccc3cccccccc00000000000000000000000000000000000000000000000000000000
fcf00fcffcc77ccffcf00fcfcccfccf03ccfccc7cccfccf0fccccccffccccccffccccccf00000000000000000000000000000000000000000000000000000000
3cc77ccffccccccffcc77cc3ccccfcc7cccfccc3ccfcccc73ccccccffccccccffcccccc300000000000000000000000000000000000000000000000000000000
3cccccc33cccccc33cccccc3ccccccc3ccccccc3ccccccc33cccccc33cccccc33cccccc300000000000000000000000000000000000000000000000000000000
3ffcccc33ffccff33ccccff33cffcc333ccffc333cccff333ffcccc33ffccff33ccccff300000000000000000000000000000000000000000000000000000000
3b3b3b3b666566650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b3b3b3b3666577750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3b3b3b3b666555550000000000000000000aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b3b3b3b37775666500000000000a900000a994000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3b3b3b3b55556665000000770009400000a994000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b3b3b3b3666577750000000000000000000440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3b3b3b3b666555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b3b3b3b3666566650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000006cc100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000006cc100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000066666666000066666666006cc100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0006cccccccc1000cccccccc006cc100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
006cccccccccc100cccccccc006cc100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
006ccc1111ccc10011111111006cc100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
006cc100006cc10000000000006cc100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
006cc100006cc10000000000006cc100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
006cc100006cc1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
006cc100006cc1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
006ccc6666ccc1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
006cccccccccc1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0006cccccccc10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777777777777777777777777777777777777777777770000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777777777777777777777777777777777777777777770000000000000000000000000000000000000000000000000000000000000000
77888888888888888888888887777777777777777777777777777777777777770000000000000000000000000000000000000000000000000000000000000000
77887777887787787788778887775557755577775557557777777777777777770000000000000000000000000000000000000000000000000000000000000000
77887787787787787788778887777777777777777777777707000007777777770000000000000000000000000000000000000000000000000000000000000000
77887787787787787778778887775755557557775755577007077007777777770000000000000000000000000000000000000000000000000000000000000000
77887777887787787777778887777777777777777777777707077007777777770000000000000000000000000000000000000000000000000000000000000000
77887787787787787787778887775557555757775557557707077707007777770000000000000000000000000000000000000000000000000000000000000000
77887787787787787788778887777777777777777777777707007707070777770000000000000000000000000000000000000000000000000000000000000000
77887777888777887788778887775755575557775755757707007707007777770000000000000000000000000000000000000000000000000000000000000000
77888888888888888888888887777777777777777777777707000007077777770000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777777775557557557775575557777777777777777770000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777777777777777777777777777777777777777777770000000000000000000000000000000000000000000000000000000000000000
70000000000000000000000000000000000000000000000000000000007777770000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777777777777777777777777777777777777777777770000000000000000000000000000000000000000000000000000000000000000
7aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa70000000000000000000000000000000000000000000000000000000000000000
7aaaaaaaaaaaa444444444aa000a000aa0aa0a0aaaa0aa000aaaaaaaaaaaaaa70000000000000000000000000000000000000000000000000000000000000000
7aaaaaaaaaaaa4aaa4aaa4aa0aaaa0aa0a0a0a0aaa0a0aa0aaaaaaaaaaaaaaa70000000000000000000000000000000000000000000000000000000000000000
7aaaaaaaaaaaa444444444aa000aa0aa000aa0aaaa000aa0aaaaaaaaaaaaaaa70000000000000000000000000000000000000000000000000000000000000000
7aaaaaaaaaaaa4aaa4aaa4aaaa0aa0aa0a0aa0aaaa0a0aa0aaaaaaaaaaaaaaa70000000000000000000000000000000000000000000000000000000000000000
7aaaaaaaaaaaa4a4a4a4a4aa000aa0aa0a0aa0aaaa0a0aa0aaaaaaaaaaaaaaa70000000000000000000000000000000000000000000000000000000000000000
7aaaaaaaaaaaa4a4a4a4a4aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa70000000000000000000000000000000000000000000000000000000000000000
7aaaaaaaaaaaa4aaa4aaa4aa00aa00aa0000aa0aaaa0a0000aaaaaaaaaaaaaa70000000000000000000000000000000000000000000000000000000000000000
7aaaaaaaaaaaa444444444aa00aa00a00aa00a00aa00a00aaaaaaaaaaaaaaaa70000000000000000000000000000000000000000000000000000000000000000
7aaaaaaaaaaaa4aaa4aaa4aa000000a00aa00a000000a000aaaaaaaaaaaaaaa70000000000000000000000000000000000000000000000000000000000000000
7aaaaaaaaaaaa4a4a4a4a4aa00aa00a00aa00a00aa00a00aaaaaaaaaaaaaaaa70000000000000000000000000000000000000000000000000000000000000000
7aaaaaaaaaaaa4aaa4aaa4aa00aa00aa0000aa00aa00a0000aaaaaaaaaaaaaa70000000000000000000000000000000000000000000000000000000000000000
7aaaaaaaaaaaa444444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa70000000000000000000000000000000000000000000000000000000000000000
7aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa70000000000000000000000000000000000000000000000000000000000000000
7aaaaaaaaaaaa000000000000000000000000000000000000aaaaaaaaaaaaaa70000000000000000000000000000000000000000000000000000000000000000
7aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa70000000000000000000000000000000000000000000000000000000000000000
71111111111111111111111111111111111111111111111111111111111111170000000000000000000000000000000000000000000000000000000000000000
71111111111111111111111111111111111111111111111111111111111111170000000000000000000000000000000000000000000000000000000000000000
71111111111111111111111111111111111111111111111111111111111111170000000000000000000000000000000000000000000000000000000000000000
71111111111111111111111111111111111111111111111111111111111111170000000000000000000000000000000000000000000000000000000000000000
71117777777777777777777777777777777777777777777777777777777771170000000000000000000000000000000000000000000000000000000000000000
71117777777777777777777777777777777777777777777111111111111171170000000000000000000000000000000000000000000000000000000000000000
71117711771177717711171117717711177111717171117177117171177171170000000000000000000000000000000000000000000000000000000000000000
71117717171717171771771777171771777717717171777171717171711171170000000000000000000000000000000000000000000000000000000000000000
71117711771177171771771177177771777717711171177171717771771171170000000000000000000000000000000000000000000000000000000000000000
71117717771717171771771777171771777717717171777171717171117171170000000000000000000000000000000000000000000000000000000000000000
71117717771717717771771117717771777717717171117171717171771171170000000000000000000000000000000000000000000000000000000000000000
71117777777777777777777777777777777777777777777111111111111171170000000000000000000000000000000000000000000000000000000000000000
71117777777777777777777777777777777777777777777777777777777771170000000000000000000000000000000000000000000000000000000000000000
71111111111111111111111111111111111111111111111111111111111111170000000000000000000000000000000000000000000000000000000000000000
71111111111111111111111111111111111111111111111111111111111111170000000000000000000000000000000000000000000000000000000000000000
71111111111111111111111111111111111111111111111111111111111111170000000000000000000000000000000000000000000000000000000000000000
78888888888888888888888888888888888888888888888888888888888888870000000000000000000000000000000000000000000000000000000000000000
78888888888888888888888888888888888888888888888888888888888888870000000000000000000000000000000000000000000000000000000000000000
78888888888888888888888888888888888888888888888888888888888888870000000000000000000000000000000000000000000000000000000000000000
78888888888888888888888888888888888887888888888888888888888888870000000000000000000000000000000000000000000000000000000000000000
78888888888888888888888888888888888887888888888888888888888888870000000000000000000000000000000000000000000000000000000000000000
78888888887787788888888888888888888887888888888888888888888888870000000000000000000000000000000000000000000000000000000000000000
78888888877777778888778778878788788887878787887888778888888888870000000000000000000000000000000000000000000000000000000000000000
78888888877777778887888887878787878887888787878787888888888888870000000000000000000000000000000000000000000000000000000000000000
78888888887777788887778777878787778887878787877787778888888888870000000000000000000000000000000000000000000000000000000000000000
78888888887777788888878787877787888887878777878888878888888888870000000000000000000000000000000000000000000000000000000000000000
78888888888777888887788777887888778887878878887787788888888888870000000000000000000000000000000000000000000000000000000000000000
78888888888878888888888888888888888888888888888888888888888888870000000000000000000000000000000000000000000000000000000000000000
78888888888888888888888888888888888888888888888888888888888888870000000000000000000000000000000000000000000000000000000000000000
78888888888888888888888888888888888888888888888888888888888888870000000000000000000000000000000000000000000000000000000000000000
78888888888888888888888888888888888888888888888888888888888888870000000000000000000000000000000000000000000000000000000000000000
78888888888888888888888888888888888888888888888888888888888888870000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777777777777777777777777777777777777777777770000000000000000000000000000000000000000000000000000000000000000
__map__
1010101010101010101010101010101040414243444546472022222222222115152022222222222100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101050515253545556572313131313132315152313131313132300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101060616263646566672313202221133022223113202221132300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101070717273747576772314302231131313131313302231142300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101080818283848586872313131313132022222113131313132300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101090919293949596973022222221132315002313202222223100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10101010101010101010101010101010a0a1a2a3a4a5a6a72022222231133022223113302222222100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10101010101010101010101010101010b0b1b2b3b4b5b6b72313131313131313131313131313132300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000002314231320222222222222211323142300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000002313231330222221202222311323132300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000002313231313131330311313131323132300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000002313302222221313131322222231132300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100000000000000002313131313131320211313131313132300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121200000000000000003022222222222231302222222222223100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010100003c0503b050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
