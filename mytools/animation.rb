require "sketchup.rb"
#load("/Users/Jing/Library/Application Support/SketchUp 2013/SketchUp/Plugins/mytools/animation.rb")

module CWRU
	
	def CWRU.generate_random_mts(observer, slowest, fastest, ndirections)
		t = observer.transformation
		mts = Array.new(ndirections)
		(0...ndirections).each{ |i|
			angle = rand * 2 * 3.14
			rotation = Geom::Transformation.rotation t.origin, t.zaxis, angle
			direction = t.xaxis.transform rotation
			if direction.length - 1 > 0.001 && direction.length - 1 < 0.001 
				puts "generate_random_direction error!!!"
			end
			speed= rand * (fastest - slowest) + slowest
			direction.length= speed
			mts[i] = Geom::Transformation.translation direction
		
			# puts "angle:#{angle}, speed:#{speed}"
		}
		return mts
	end
	
	class FixationAnimation
		def initialize(walk_opts, animation_opts)
			model=Sketchup.active_model
			view = model.active_view
			
			
			@image_width = animation_opts["width"]
			@image_height = animation_opts["height"]
			@fov = animation_opts["fov"]
			@fps = animation_opts["fps"]
			@path_to_save_to = animation_opts["path_to_save_to"]
			
			@seed = walk_opts["seed"]
			@ndirections = walk_opts["ndirections"]
			@duration = walk_opts["duration"]
			@slowest = walk_opts["slowest"].m / (@fps * 1.0)
			@fastest = walk_opts["fastest"].m / (@fps * 1.0)
			
			
			@nframes = (@duration * @fps).to_i
			Dir.mkdir(@path_to_save_to) unless File.exist?(@path_to_save_to)
			
			
			@connections = CWRU.get_connections(model)
			@cur_connection_index= 0
			@cur_frame_index = 0
			@cur_mts_index = 0

			if startNewConnection()
			  startNewDirection()
			end
		end
		
		def startNewConnection()
			if @cur_connection_index >= @connections.size
				return false
			end
			
			@cur_observer = @connections[@cur_connection_index][0]
			@cur_target 	= @connections[@cur_connection_index][1]
			@cur_mts = CWRU.generate_random_mts(@cur_observer, @slowest, @fastest, @ndirections)
			observerId=CWRU.get_observerId(@cur_observer)
			targetId = CWRU.get_targetId(@cur_target)
			@cur_prefix = "C#{observerId}_F#{targetId}_"
			@cur_obs_org_transform = @cur_observer.transformation
			return true
		end
		
		def startNewDirection() 
			@cur_observer.transformation=@cur_obs_org_transform
			@cur_dir = File.join(@path_to_save_to, @cur_prefix + "D#{@cur_mts_index}")
			puts @cur_dir
			if  File.exists?(@cur_dir)
			  return false
			else
			  Dir.mkdir(@cur_dir)
			  return true
			end

		end
	
		def nextFrame(view)
			# if all animations are finished or no connection need to be animated, return false
			if @cur_frame_index >= @nframes || @cur_mts_index >= @ndirections || @cur_connection_index >= @connections.size 
				return false
			end
			
			
			eye = CWRU.get_eye_position(@cur_observer)
			up = CWRU.get_up(@cur_observer)
			target=CWRU.get_target_position(@cur_target)

			view.camera.set(eye, target, up)
			
			# save image out
			filename=File.join(@cur_dir, "#{@cur_frame_index}" + ".jpg")
			Sketchup.set_status_text("Exporting frame #{@cur_frame_index} to #{filename}")
			begin
				view.write_image(filename, @image_width, @image_height, true, 1.0)
			rescue
				UI.messagebox("Error exporting animation frame.  Check animation parameters and retry.")
				raise
			end
			
			
			# refresh the design window
			view.show_frame()
			
			# move observer
			cur_transform = @cur_observer.transformation
			@cur_observer.transformation= @cur_mts[@cur_mts_index] * cur_transform

			#update
			@cur_frame_index += 1
			if @cur_frame_index >= @nframes
			  # call finish_one_direction
			  @cur_mts_index +=1
			  
			  if @cur_mts_index >= @ndirections
				# call finish_one_pair
				@cur_connection_index +=1
				if @cur_connection_index >= @connections.size
				  return false
				end
				startNewConnection()
				@cur_mts_index = 0
			  end
			  
			  startNewDirection()
			  @cur_frame_index = 0
			end

			return true

		end
	end

end
