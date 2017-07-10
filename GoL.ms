/*
print("Deleting all boxes..")
for obj in objects where classOf obj == box do 
(
	delete obj
)
print("Done")
*/

--frames/generations to render
framecount = 20
--bounds
x_max =10
y_max = 10
z_max = 10

--starting frame
sliderTime = 0

--frames between generations
frameoffset = 10

--Rules (Standard: 2333
survive_min = 5
survive_max = 7
birth_min =6
birth_max = 6

initial_dead =50 
initial_box_resize = 1

border_x_b = 1
border_x_t = x_max
border_y_b = 1
border_y_t = y_max
border_z_b = 1
border_z_t = z_max
/*
border_x_b = 2
border_x_t = x_max-1
border_y_b = 2
border_y_t = y_max-1
border_z_b = 2
border_z_t = z_max-1
*/
color_array = #()

for i = 1 to 1 do 
(
	r = random 1 255
	g = random 1 255
	b = random 1 255
	color_array[i] = color r g b
)

--create boxes invisible
for x = 1 to x_max do
(
	for y = 1 to y_max do
	(
		for z = 1 to z_max do
		(
			newobj = box width:1 height:1 length:1 name:("box" + x as string + y as string + z as string) 
			move newobj [x,y,z]
			at time 0 newobj.material = StandardMaterial()
			at time 0 newobj.material.diffuse = color_array[1]
			newobj.visibility = bezier_float()
			with animate on 
				(
					at time 0 newobj.visibility.controller.value = 0				
				)
		)
	)
)


--create random subbox
for x = border_x_b to (x_max/initial_box_resize) do
(
	for y = border_y_b to (y_max/initial_box_resize) do
	(
		for z = border_z_b to (z_max/initial_box_resize) do
		(
			c_box = getnodebyname("box" + x as string + y as string + z as string)
			
			tmp = random 0 100
			tmp /= initial_dead
			
			with animate on 
				(
					at time 0 c_box.visibility.controller.value = tmp				
				)
		)
	)
)

--game
for i = 0 to framecount do
(	
	changed = false
	print("Frame: " + i as string)
	sliderTime = i*frameoffset			

	for x = border_x_b to border_x_t do
	(					
		x_coords = #(x-1,x,x+1)					
		if (x_coords[2] == 1) do x_coords[1] = x_max
		if (x_coords[2] == x_max) do x_coords[3] = 1
		
		for y = border_y_b to border_y_t do
		(
			y_coords = #(y-1,y,y+1)
			
			if (y_coords[2] == 1) do y_coords[1] = y_max
			if (y_coords[2] == y_max) do y_coords[3] = 1
			n_count = #(0,0,0)
			for z = border_z_b to border_z_t do
			(
				dead = false
				z_coords = #(z-1,z,z+1)				
				if (z_coords[2] == 1) do z_coords[1] = z_max
				if (z_coords[2] == z_max) do z_coords[3] = 1				
				
				c_cell = getnodebyname("box" + x as string + y as string + z as string)
				if c_cell.visibility.controller.value == 0 do dead = true

				if z == border_z_b then
				(	
					for scan_x = 1 to 3 do
					(
						for scan_y = 1 to 3 do
						(
							for scan_z = 1 to 3 do
							(
								n_cell = getnodebyname ("box" + x_coords[scan_x] as string + y_coords[scan_y] as string + z_coords[scan_z] as string)	
								
								if n_cell.visibility.controller.value >= 1 do n_count[scan_z] += 1

							)
						)
					)
				)
				else
				(
					--shift layers
					n_count[1] = n_count[2]
					n_count[2] = n_count[3]
					n_count[3] = 0
					
					for scan_x = 1 to 3 do
					(
						for scan_y = 1 to 3 do
						(
							n_cell = getnodebyname("box" + x_coords[scan_x] as string + y_coords[scan_y] as string + z_coords[3] as string)
							if n_cell.visibility.controller.value >= 1 do n_count[3] += 1
						)
					)
				)

				total_count = n_count[1] + n_count[2] + n_count[3]
				
				if dead then
				(
					if total_count >= birth_min and total_count <= birth_max then 
					(
						with animate on 
						(
							at time (sliderTime + frameoffset/4)  
							( 
								c_cell.visibility.controller.value = 1
							)
							at time (sliderTime + frameoffset) c_cell.visibility.controller.value = 1

							changed = true
						)
					)
					else 
					(
						with animate on 
						(
							at time (sliderTime + frameoffset/4)  c_cell.visibility.controller.value = 0
							at time (sliderTime + frameoffset) c_cell.visibility.controller.value = 0
						)
					)
				)
				else
				(
					total_count -= 1
					
					if total_count >= survive_min and total_count <= survive_max then
					(
						with animate on 
						(
							at time (sliderTime + frameoffset/4) c_cell.visibility.controller.value = 1
							at time (sliderTime + frameoffset) c_cell.visibility.controller.value = 1
						)
					)
					else
					(
						with animate on 
						(
							at time (sliderTime + frameoffset/4) c_cell.visibility.controller.value = 0
							at time (sliderTime + frameoffset) c_cell.visibility.controller.value = 0
							changed = true
						)	
					)
				)
			)
		)
	)
	print("Changes: " + changed as string)
	if changed == false do exit
)

/*
--Render video
curtime = timestamp()
rendTimeType = 3
rendStart = 0
rendEnd = framecount*frameoffset
renderWidth = 640
renderHeight = 480
rendSaveFile = true
rendOutputFilename = "Y:\\GOL\\" + curtime as string + ".avi"
max quick render



/*
--Render each frame to file
for f=0 to framecount do
(
	a = timestamp()
	print("Rendering frame " + f as string )
	rendTimeType = 3
	rendStart = f
	rendEnd = f	
	renderWidth = 1920
	renderHeight = 1080
	rendSaveFile = true
	rendOutputFilename = "Y:\\GOL\\" + f as string + ".png"
	max quick render
)
*/