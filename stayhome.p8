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
 food_dot_empty=36

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

	bookshop_level = {}
	bookshop_level.init = init_bookshop
	bookshop_level.draw = draw_bookshop
	bookshop_level.update = update_bookshop

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
	bookshop_id=5
	outside_id=6
	gameover_id=7
	freedom_id=8
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
	last_level = bookshop_id

	levels[title_id]=title_level
	levels[announce_id]=announce_level
	levels[freedom_id]=freedom_level
	levels[friends_id]=friends_level
	levels[gameover_id]=gameover_level
	levels[outside_id]=outside_level
	levels[pacfood_id]=pacfood_level
	levels[bookshop_id]=bookshop_level

 -- call start here to init stuff
 start_game()
	
	-- set real level_id
	set_level(title_id)
	
	-- set temp: level_id for testing	
	--set_level(bookshop_id)
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

function draw_bookshop()
 cls(6)
	rect(0,0,127,10,7)
	rectfill(1,1,126,9,1)
	print("book a food delivery slot",15,3,7)

	rect(2,12,125,20,1)
	rectfill(3,13,124,19,7)

	print("https://grubco.com",8,14,0)

	-- draw icons
	icon_x=12
	
 palt(3,true)
 palt(0,false)
	
	back_x=icon_x
	icon_y=25
	forward_x=18+icon_x
	refresh_x=36+icon_x
	stop_x=54+icon_x
	
	over_back=false
	over_forward=false
	over_refresh=false
	over_stop=false
	
	if cursor_y>=icon_y and
		cursor_y < icon_y+16 then
		-- in icon bar
		if cursor_x>=back_x and
			cursor_x < forward_x then
			over_back=true
		end
		if cursor_x>=forward_x and
			cursor_x < refresh_x then
			over_forward=true
		end
		if cursor_x>=refresh_x and
			cursor_x < stop_x then
			over_refresh=true
		end
		if cursor_x>=stop_x and
			cursor_x < stop_x+16 then
			over_stop=true
		end
	end
	
	
	
 spr(21,back_x,icon_y,2,2)
 if over_back then
  spr(29,back_x,icon_y,2,2)
 end	
 spr(23,forward_x,icon_y,2,2)
 if over_forward then
	 spr(29,forward_x,icon_y,2,2)
 end
 spr(25,refresh_x,icon_y,2,2)
 if over_refresh then
	 spr(29,refresh_x,icon_y,2,2)
 end
 spr(27,stop_x,icon_y,2,2)
 if over_stop then
  spr(29,stop_x,icon_y,2,2)
 end
	rect(2,23,125,42,5)

	if book_page=="booking" then
		draw_book_page()
	end
	if book_page=="error" then
		draw_book_error_page()
	end
	if book_page=="queue" then
		draw_book_queue_page()
	end
	if book_page=="booked" then
		draw_booked_page()
	end

 palt(3,true)
 palt(0,false)
	spr(9,cursor_x,cursor_y,1,1)
	palt(3,false)


	draw_intro_text()
end

function draw_book_error_page()
	print("500:internal service error",10,64,8)
end

function draw_booked_page()
 print("you have a delivery slot",18,66,3)
 print("see you soon",38,74,3)
end

function draw_book_queue_page()
 print("you are number "..queue_number,24,66,1)
 print("in a queue",34,74,1)
end



function draw_book_page()
	print("(booked)",86,26,8)
	print("(free)",90,34,3)

	-- draw slots available
	rect(2,44,125,126,1)
	print(" m  t  w  t  f  s  s",28,46,1)
	line(2,52,125,52,1)
	booked_colour=8

	-- draw times	 
	for i=10,21 do
		print(""..i..":00",4,54+(i-10)*6,1)		
	end
	line(24,52,24,125,1)
	 
	slot_w=6
	slot_h=6
	over_slot=0
	--to_draw=
	for i=1,show_slots do
	 slot=slots[i]
	 -- check if mouse is inside slot
	 if cursor_x >= slot.x and
	 	cursor_x <= slot.x +slot_w and
	 	cursor_y >= slot.y and
			cursor_y <= slot.y+slot_h then
		 rectfill(slot.x,slot.y-1,slot.x+slot_w,slot.y-1+slot_h,1)
		 over_slot=i
		end
	 if slot.booked then
			print("xx",slot.x,slot.y,8)
		else		 	
		 print("--",slot.x,slot.y,3)
	 end
	end
	 
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

function init_bookshop()
	intro_text = {"oh dear!", "you've run out of food", "you need to", "book a home delivery","", "keep refreshing", "use `z` to click"}
	intro_timer = 120
	refresh_clicks=0
	clicks_til_queue=5
	cursor_x=64
	cursor_y=64
	book_page="error"
	init_slots(true)
end

function init_slots(booked)
 over_slot=0
	queue_number=15000
	slots_free=false
	clicks_til_slot=10
	got_a_slot=false
	frame_counter=0
	slot_counter=1
	show_slots=0
	slots={}
	for d=1,7 do
		-- one column per day
		for t=1,12 do
			slot={}
			slot.day=d
			slot.time=t
			slot.x=18+d*4*3
			slot.y=54+(t-1)*6
			slot.booked=booked
			add(slots,slot)
		end
	end
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
	question2.text="see mum on mother's day"
	question2.correct="you should say no!"
	question2.wrong1="no problem"
	question2.wrong2="i'll be round later"
	questions[2]=question2

	question3 = {}
	question3.text="can go out and buy makeup"
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
 max_kids=20
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
 		change_direction(kid)		
		else
		 kid.dir_count=kid.dir_count-1
			kids[i]=move_kid(kid)
		end
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

function update_bookshop()
	frame_counter = frame_counter +1

 if book_page=="queue" then
 	queue_number=queue_number-flr(rnd(100))
 	if queue_number<0 then
 		book_page="booking"
 		init_slots(false)
 	end 	
 end
 
 if book_page=="booked" then
 	-- wait for a bit then next level
 	if frame_counter>120 then
 		next_level()
 	end
 end
 
	-- update bookings
	for i=1,3 do
		slot=slots[flr(rnd(#slots))+1]
	end
	
 -- update which slots are drawn
	if intro_timer==0 and show_slots <= #slots and book_page=="booking" then
		if frame_counter > slot_counter then
			frame_counter=0			
			-- increase number of slots to show
			if show_slots < #slots then
	 		show_slots=show_slots+7
	 		if show_slots>#slots then
	 			show_slots=#slots
	 		end
			end
		end
	end
	
	slot.booked=true
	if (btn(0)) and cursor_x > 0 then
		cursor_x = cursor_x-1 
	end
	if (btn(1)) and cursor_x < 124 then
		cursor_x = cursor_x+1 
	end
	if (btn(2)) and cursor_y > 0 then
		cursor_y = cursor_y-1 
	end
	if (btn(3)) and cursor_y < 124 then
		cursor_y = cursor_y+1 
	end
	
	if (btnp(4)) then
		-- clicked
		if over_refresh then
			refresh()
		end
		if book_page=="booking" then
			-- check slot
			if over_slot!=0 then
				-- check if slot already book
				slot=slots[over_slot]
				print("over:"..over_slot)
				if not slot.booked then
					slot.booked=true
					book_page="booked"
					frame_counter=0
					food=100
					days=days+1
					score=score+100
				end
			end
		end
	end
end

function refresh()
	show_slots=0
	refresh_clicks=refresh_clicks+1
	if refresh_clicks>=clicks_til_queue then
 	book_page="queue"
 	days=days+1
 	refresh_clicks=0
	else
 	book_page="booking"
	end
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

	if food < 1 then
		next_level()
	end
end

function update_title()
 update_frame(player)
	if (btnp()>0) then start_game() end
end
__gfx__
333333333cc33cc333333333333333333333cc3333333333333333333cc33cc33333333330333333000000000000000000000000000000000000000000000000
3cc33cc3c77cc77c3cc33cc33333cc333cccc7733333cc333cc33cc3cccccccc3cc33cc307033333000000000000000000000000000000000000000000000000
c77cc77cc70cc07cc77cc77c3cccc773ccccc7033cccc773cccccccccccccccccccccccc07703333000000000000000000000000000000000000000000000000
c70cc07c3cf00fc3c70cc07cccccc703ccccccf0ccccc703cccccccc3cccccc3cccccccc07770333000000000000000000000000000000000000000000000000
fcf00fcffcc77ccffcf00fcfcccfccf03ccfccc7cccfccf0fccccccffccccccffccccccf07777033000000000000000000000000000000000000000000000000
3cc77ccffccccccffcc77cc3ccccfcc7cccfccc3ccfcccc73ccccccffccccccffcccccc307700333000000000000000000000000000000000000000000000000
3cccccc33cccccc33cccccc3ccccccc3ccccccc3ccccccc33cccccc33cccccc33cccccc330070333000000000000000000000000000000000000000000000000
3ffcccc33ffccff33ccccff33cffcc333ccffc333cccff333ffcccc33ffccff33ccccff333333333000000000000000000000000000000000000000000000000
3b3b3b3b666566650000000000000000000000006777777777777776677777777777777667777777777777766777777777777776655555555555555600000000
b3b3b3b3666577750000000000000000000000007666666666666665766666666666666576666666666666657666666666666665533333333333333700000000
3b3b3b3b666555550000000000000000000aa0007666667766666665766666667766666576677777766666657666777777776665533333333333333700000000
b3b3b3b37775666500000000000a900000a99400766667c066666665766666667c766665767ccccc066666657667888888887665533333333333333700000000
3b3b3b3b55556665000000770009400000a9940076667cc066666665766666667cc7666577cccccc067066657678888888888065533333333333333700000000
b3b3b3b3666577750000000000000000000440007667ccc066666665766666667ccc766577ccc00007cc06657678888888888065533333333333333700000000
3b3b3b3b66655555000000000000000000000000767ccccc7777777577777777ccccc76577cc06667cccc0657678777777778065533333333333333700000000
b3b3b3b36665666500000000000000000000000077cccccccccccc0577cccccccccccc7577cc0667cccccc057678777777778065533333333333333700000000
000000000000000000000000006cc1000000000077cccccccccccc0577cccccccccccc0577cc066777cc00057678777777778065533333333333333700000000
000000000000000000000000006cc10000000000767ccccc0000000577000000ccccc06577cc066667cc06657678777777778065533333333333333700000000
000066666666000066666666006cc100000000007667ccc066666665766666667ccc066577ccc7777ccc06657678888888888065533333333333333700000000
0006cccccccc1000cccccccc006cc1000000000076667cc066666665766666667cc0666577cccccccccc06657678888888888065533333333333333700000000
006cccccccccc100cccccccc006cc10000000000766667c066666665766666667c066665767cccccccc066657667888888880665533333333333333700000000
006ccc1111ccc10011111111006cc100000000007666667066666665766666667066666576600000000666657666000000006665533333333333333700000000
006cc100006cc10000000000006cc100000000007666666666666665766666666666666576666666666666657666666666666665533333333333333700000000
006cc100006cc10000000000006cc100000000006555555555555556655555555555555665555555555555566555555555555556677777777777777600000000
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
1010101010101010101010101010101040414243444546472022222222222124242022222222222100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101050515253545556572313131313132324242313131313132300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101060616263646566672313202221133022223113202221132300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101070717273747576772314302231131313131313302231142300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101080818283848586872313131313132022222113131313132300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101090919293949596973022222221132324002313202222223100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
