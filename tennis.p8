pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

-- intro | game | end
scene = 'intro'

function _init()
  reset_game()
end

function reset_game()
  -- amy positon= [-3 ... 3]
  amy_position = 0
  -- -1, 0, 1
  amy_direction = 0
  rouge_position = 0
  amy_rocket = 0
  AMY_Y = 100
  ROUGE_Y = 16
  direction_reset_timer = 0
  DIRECTION_RESET_FRAMES = 8
  stimer = 0
  ANIMATION_SPEED = 5
  walking_animation_phase = 0
  draw_ball_effect = 0
  score1 = 0
  score2 = 0
  parts = {}
  for i = 1,10 do
    add(parts, { dx = rnd(3) - 6, dy = rnd(4) -8, speed = (rnd(1)-2) / 3, r = rnd(3), c = 14 })
  end
  reset_ball()
end

function reset_ball()
  ball_y = 16
  ball_x = 64
  rouge_position = 0
  amy_position = 0
  ball_ax = 0
  ball_ay = 1.68
  ball_speed_x = 1.15
  ball_speed = 1.75
  sfx(04)
end

function _draw()
  if scene == 'game' then draw_game() end
  if scene == 'intro' then draw_intro() end
end

function draw_game()
  draw_map()
  draw_ball()
  --draw_particles()
  draw_amy()
  draw_rouge()
  draw_hud()
end

function draw_intro()
  cls(0)
  -- amy and rocket
  sspr(6 * 8, 2 * 8, 8, 16, 12, 48, 16, 32, true)
  sspr(5 * 8, 0, 8, 16, 0, 48, 16, 32)
  -- rouge
  sspr(4 * 8, 0, 8, 16, 100, 48, 16, 32)
  sspr(5 * 8, 0, 8, 16, 108, 48, 16, 32, true)

  print('Amy und rouge', 40, 32, 14)
  print('tennis', 52, 40)

  print('press (🅾️) or (❎)', 32, 60)
  print('to start', 48, 68)
end

function draw_map()
  cls(0)
  sspr(7 * 8, 0, 9 * 8, 9 * 8, 0, 0, 128, 128)
end

function draw_amy()
  x = amy_position * 16 + 60
  y = AMY_Y
  if amy_direction == -1 then
    sspr((6 - walking_animation_phase) * 8, 2 * 8, 8, 16, x, y, 8, 16, false)
  end
  if amy_direction == 0 then
    spr(6, x, y)
    spr(22, x, y + 8)
  end
  if amy_direction == 1 then
    sspr((6 - walking_animation_phase) * 8, 2 * 8, 8, 16, x, y, 8, 16, true)
  end

  if amy_rocket == 1 then
    spr(5, x - 8, 100)
    spr(21, x - 8, 108)
  end
end

function draw_rouge()
  x = rouge_position * 16 + 60
  spr(4, x, ROUGE_Y)
  spr(20, x, ROUGE_Y + 8)
end

function update_amy()
  is_animation_frame = stimer % ANIMATION_SPEED == 0
  -- controls
  if btnp(➡️) and amy_position < 3 then
    amy_position += 1
    amy_direction = 1
    direction_reset_timer = DIRECTION_RESET_FRAMES
  end
  if btnp(⬅️) and amy_position > -3 then
    amy_position -= 1
    amy_direction = -1
    direction_reset_timer = DIRECTION_RESET_FRAMES
  end
  amy_rocket = (btnp(🅾️) or btnp(❎)) and 1 or 0
  -- animation
  if direction_reset_timer > 0 then
    direction_reset_timer -= 1
  else
    direction_reset_timer = 0
    amy_direction = 0
  end
  if is_animation_frame then
    walking_animation_phase = walking_animation_phase == 0 and 1 or 0
  end
end

function update_stimer()
  if stimer > 30 then
    stimer = 0
  else
    stimer += 1
  end
end

function update_collisions()
  -- amy hits back
  amy_x = amy_position * 16 + 60
  if abs(ball_y - AMY_Y) < 4
      and abs(ball_x - amy_x) < 16
      and ball_ay > 0
      and amy_rocket == 1 then
    ball_speed += 0.1
    ball_ay = ball_speed * (abs(ball_ay) == ball_ay and -1 or 1)
    ball_ax = rnd(ball_speed_x) * (rnd(2) > 1 and -1 or 1)
    draw_ball_effect = ANIMATION_SPEED
    sfx(00)
  end
  -- rouge hits back
  if abs(ball_y - ROUGE_Y) < 4 and ball_ay < 0 then
    ball_speed += 0.1
    ball_ay = ball_speed * (abs(ball_ay) == ball_ay and -1 or 1)
    ball_ax = rnd(ball_speed_x) * (rnd(2) > 1 and -1 or 1)
    draw_ball_effect = ANIMATION_SPEED
    sfx(01)
  end
  -- ball out of bounds, amy side
  if ball_y > AMY_Y + 8 then
    reset_ball()
    score2 += 1
  end
  -- ball out of bounds, rouge side
  if ball_y < ROUGE_Y - 8 then
    reset_ball()
    score1 += 1
  end
  -- ball out of bounds on ox - just reset
  if ball_x < 10 or ball_x > 110 then
    reset_ball()
  end
end

function update_animation()
  if draw_ball_effect > 0 then draw_ball_effect -= 1 end
end

function update_game()
  update_stimer()
  update_amy()
  update_rouge()
  update_ball()
  --update_particles()
  update_collisions()
  update_animation()
end

function update_intro()
  if btnp(🅾️) or btnp(❎) then scene = 'game' end
end

function _update()
  if scene == 'game' then update_game() end
  if scene == 'intro' then update_intro() end
end

function update_rouge()
  rouge_x = 60 + rouge_position * 16
  if ball_ay < 0 and is_animation_frame then
    if abs(rouge_x - ball_x) > 8 then
      rouge_position += rouge_x > ball_x and -1 or 1
    end
  end
  if rouge_position > 3 then rouge_position = 3 end
  if rouge_position < -3 then rouge_position = -3 end
end

function draw_ball()
  ball_normal_size = 4
  -- ball has to be bigger in the middle, normal on the sides
  ball_scale = (ball_y > 24 and ball_y < 38 or ball_y > 80 and ball_y < 96) and 1 or 1.5
  sspr(3 * 8, 0, 8, 8, ball_x, ball_y, ball_normal_size * ball_scale, ball_normal_size * ball_scale)
  if draw_ball_effect > 0 then
    sspr(3 * 8, 1 * 8, 8, 8, ball_x - 8, ball_y - 8, 16, 16)
  end
end

function draw_particles()
  for p in all(parts) do
    circfill(ball_x - 4 + p.dx, ball_y - 4 + p.dy, p.r, p.c)
  end
end

function  update_particles()
  for p in all(parts) do
    p.dx += p.speed
    p.dy += p.speed
  end
  
end

function draw_hud()
  print('Amy ' .. score1 .. ' Rouge ' .. score2, 0, 0, 14)
end

function update_ball()
  ball_x += ball_ax
  ball_y += ball_ay
end

__gfx__
000000000000000000000000007777007500057f069999600e2000e0a499aa999aa999a4cdccccddcdccdccdcdcccdcccdcdcccddccccccca4999a999aa9999a
00000000000000000000000007aaaa70775007ff690770962eeeeee2aa999a4999a4994acccdcdcdccccccccdccccccdccccccddcccccdcca999aa999a99994a
0000000000000000000000007aaaa6a7f77557ff90900909eeeee2ee3a4994a9994a999aaccccccddcdccdccdccdcccdccccdcddccdccccda999aa994a9999a3
0000000000000000000000007aaa6aa777777777900a9009eeeeeeee33a999a4999aa999acdccdccdcccccccdccccccddcccccdcccccccca499aa999a49994a3
0000000000000000000000007aaa6aa77767767790090a09eeeeeeee33aa994a9999a4999cccdcccdcdcdcccdcdccdcdccdcccdcccccdcda999aa999a9999a33
0000000000000000000000007a66aaa77777777590900909e2eeee2e333a999aa999aa999ddcccdcdccccccddccccccdcccccddccdccccaa999a9994a9994a33
00000000000000000000000007aaaa707ff7ff77690770962e2ee2e2333aa994a9999a4999cccdccdcccdcccdccdcccdcdcccdccccccdcaa994a999a4999a333
000000000000000000000000007777000ffffff706999960020220203333a499aa9994a999cdcccccdccccccdccccccdcccccdcccccccda999aa994a4a94a333
000000000000000000000000000000000efffe6000000999660888003333aa99bab999ab99bccccccdccccccdccccccdcccccdcccccccaaaaaaaaaaaaaaa3333
000000000000000000000000000000006eeeee66000000696688887033333aaaaaaaaaaaaadcdccccdddddddddddddddddddddddddddd66ddddddddd33da3333
000000000000000000000000ed000000602e2006000000666088886033333dddddddddddd66666666666666666666666666666666666666dddddddddddd33333
000000000000000000000000ed00000002eee200000000090088880033333333dddddddddddddddddddddddddddddddddddddddddddddddd3333333333333333
000000000000000000000000ed00000002e0e2000000000007777770333333333333333333333333333333333333333333333333333333333333333333333333
000000000000000000000000ed00000002e0e20000000000008008003333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333333
00000000000000000000000002dddd20555055500000000088700778333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333333
00000000000000000000000000eeee0055505555000000008880088833333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333
00000000000000000000000000000000000000002eee20002eee200033333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333
0000000000000000000000000000000000000000eeeee200eeeeee203333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333
0000000000000000000000000000000000000000eeeeee20eeeeeee2333bbbbbbbbbb6bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb6bbbbbbbbbbb33
0000000000000000000000000000000000000000e772eeeee772eeee33bbbbbbbbbb777777777777777777777777777777777777777777777776bbbbbbbbbbb3
0000000000000000000000000000000000000000275eeeee07522eee33bbbbbbbbbb77bbbbb676bbbbbbbbbbbbbbbbbbbbbbbbbbbb676bbbbb77bbbbbbbbbbbb
00000000000000000000000000000000000000000fff20ee0fff26ee3bbbbbbbbbb67bbbbbb66bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66bbbbbb77bbbbbbbbbbb
000000000000000000000000000000000000000005ffeeee05ffeeeebbbbbbbbbbb76bbbbbb7bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7bbbbbb676bbbbbbbbbb
0000000000000000000000000000000000000000000722ee000722e0bbbbbbbbbb77bbbbbb66bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66bbbbbb77bbbbbbbbbb
00000000000000000000000000000000000000006668806666688066bbbbbbbbb67bbbbbbb7bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb67bbbbbbb77bbbbbbbbb
00000000000000000000000000000000000000006688880666888806bbbbbbbbb76bbbbbb67777777777777777777777777777777777776bbbbbb676bbbbbbbb
00000000000000000000000000000000000000000008888800088888bbbbbbbb77bbbbbbb76bbbbbbbbbbbbbbbb67bbbbbbbbbbbbbbbb67bbbbbbb776bbbbbbb
00000000000000000000000000000000000000000087887800878878667777777777777777777777777777777777777777777777777777777777777777777777
00000000000000000000000000000000000000000770766707707667bbb6bb677b6bbbbb76bbbbb6bbbbb6bbbbbb7bbbbbb6bbbbbb6bbb66b6bbbbb666bbbbb6
00000000000000000000000000000000000000000006060088000878bbb6bb676b6bbbbb7bbbbbb6bbbbb6bbbbbb7bbbbbb6bbbbbb6bbbb7b6bbbbbb676bbbb6
00000000000000000000000000000000000000000008880088800888bbb6b677bb6bbbb666bbbbb6666bb6bbbbbb7bbbbbb6bbbbbb6bbbb666bbbbb6677bbbb6
0000000000000000000000000000000000000000008888000888008866666d66666666666d666666bb6666666666766666666666666666667666666666776666
00000000000000000000000000000000000000000000000000000000bbb6776bbb6bbb66b6bbbbb6bbbbb6bbbbbb7bbbbbb6bbbbbb6bbbbb66bbbbb66b77bbb6
00000000000000000000000000000000000000000000000000000000bbb667bbbb6bbb7bb6bbbbb6bbbbb6bbbbbb6bbbbbb6bbbbbb6bbbbbd6bbbbbb6b66bbb6
00000000000000000000000000000000000000000000000000000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
00000000000000000000000000000000000000000000000000000000bbbb6bbbbbbbb6bbbbbbbbbbbbbbbbbbbbbb6bbbbbbbbbbbbbbbbbbbb66bbbbbbbbb7bbb
00000000000000000000000000000000000000000000000000000000bbb66bbbbbbb66bbbbbbbbbbbbbbbbbbbbbb7bbbbbbbbbbbbbbbbbbbbb7bbbbbbbbb66bb
00000000000000000000000000000000000000000000000000000000bbb7bbbbbbbb7bbbbbbbbbbbbbbbbbbbbbbb7bbbbbbbbbbbbbbbbbbbbb66bbbbbbbbb76b
00000000000000000000000000000000000000000000000000000000bb66bbbbbbbb7bbbbbbbbbbbbbbbbbbbbbbb7bbbbbbbbbbbbbbbbbbbbbb7bbbbbbbbbb7b
00000000000000000000000000000000000000000000000000000000bb7bbbbbbbb66bbbbbbbbbbbbbbbbbbbbbbb7bbbbbbbbbbbbbbbbbbbbbb76bbbbbbbbb66
00000000000000000000000000000000000000000000000000000000b66bbbbbbbb7bbbbbbbbbbbbbbbbbbbbbbbb7bbbbbbbbbbbbbbbbbbbbbb66bbbbbbbbbb7
00000000000000000000000000000000000000000000000000000000b7bbbbbbbb66bbbbbbbbbbbbbbbbbbbbbbbb7bbbbbbbbbbbbbbbbbbbbbbb7bbbbbbbbbb6
0000000000000000000000000000000000000000000000000000000076bbbbbbbb7bbbbbbbbbbbbbbbbbbbbbbbbb7bbbbbbbbbbbbbbbbbbbbbbb66bbbbbbbbbb
000000000000000000000000000000000000000000000000000000006bbbbbbbb66bbbbbbbbbbbbbbbbbbbbbbbbb7bbbbbbbbbbbbbbbbbbbbbbbb7bbbbbbbbbb
00000000000000000000000000000000000000000000000000000000bbbbbbbbb7bbbbbbbbbbbbbbbbbbbbbbbbbb7bbbbbbbbbbbbbbbbbbbbbbbb66bbbbbbbbb
00000000000000000000000000000000000000000000000000000000bbbbbbbb6766666666666666666666666666766666666666666666666666667bbbbbbbbb
00000000000000000000000000000000000000000000000000000000bbbbbbbb76bbbbbbbbbbbbbbbbbbbbbbbbbb6bbbbb666666666666666666667bbbbbbbbb
00000000000000000000000000000000000000000000000000000000bbbbbbbb6bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66bbbbbbbb
00000000000000000000000000000000000000000000000000000000bbbbbbb66bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7bbbbbbbb
00000000000000000000000000000000000000000000000000000000bbbbbbb7bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66bbbbbbb
00000000000000000000000000000000000000000000000000000000bbbbbb66bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7bbbbbbb
00000000000000000000000000000000000000000000000000000000bbbbbb7bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66bbbbbb
00000000000000000000000000000000000000000000000000000000bbbbb66bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7bbbbbb
00000000000000000000000000000000000000000000000000000000bbbbb7bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7bbbbbb
00000000000000000000000000000000000000000000000000000000bbbb66bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66bbbbb
00000000000000000000000000000000000000000000000000000000bbbb7bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7bbbbb
00000000000000000000000000000000000000000000000000000000bbb66bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66bbbb
00000000000000000000000000000000000000000000000000000000bbb76bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb67bbbb
00000000000000000000000000000000000000000000000000000000bbb77777777777777777777777777777777777777777777777777777777777777777bbbb
00000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
__sfx__
0002000000000276502765026650210502105021050200501e0501c0501a050190501805017050170501705018050190501a0501c0501e0502005023050250502605027050277502675027750277500000000000
00010000005003263032640326302c5302955024550275502a5502c5502c5502c5502c5502a550295502755024550205501b550125500f55013550185501b5501d5501e550225502655027550275500050000500
0007000000100001000010036150361503615036150361503415033150311502f1502e1502b15029150271502515022150201501e1501b1501915018150161501515013150101500f1500e150091500010000100
00050000000000615007150081500a1500b1500e1500f150111501215013150151501515017150171501815002150011500115001140011400110001100011000110001100011000210002100021000010000000
0008000000000000000a5500a5500a5500a5500a5500a5500a5500a5000a5000b5001f1001f1001f1001f1001f100000001f1001f1001f1001f10000000000000000000000000000000000000000000000000000
