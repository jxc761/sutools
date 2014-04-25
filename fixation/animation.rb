require "sketchup.rb"


module CWRU
	class FixationAnimation
		def initialize(walk_opts, animation_opts)
			model=Sketchup.active_model
			view = model.active_view
			
			
			@seed = walk_opts["seed"]
			@ndirections = walk_opts["ndirections"]
			@duration = walk_opts["duration"]
		
		
			@image_width = animation_opts["width"]
			@image_height = animation_opts["height"]
			@fov = animation_opts["fov"]
			@fps = animation_opts["fps"]
			@path_to_save_to = animation_opts["path_to_save_to"]
		
		
			@slowest = walk_opts["slowest"].m / (@fps * 1.0)
			@fastest = walk_opts["fastest"].m / (@fps * 1.0)
			
			
			@nframes = (@duration * @fps).to_i
			Dir.mkdir(@path_to_save_to) unless File.exist?(@path_to_save_to)
			
			
			@connections = CWRU.get_connections(model)
			@nconnections = @connections.size
			
			@cur_export_path = ""
			@cur_connection_index= 0
			@cur_frame_index = 0
			@cur_mts_index = 0
			
			
			
			@observer = observer
			@target_position = CWRU.get_target_position(target)
			@mt = mt
			@torg = observer.transformation
			
		end
		
		def startNewConnection()
			@cur_observer = @connections[@cur_connection_index][0]
			@cur_target = @connnections[@cur_connection_index][1]
			@cur_mts = CWRU.generate_random_mts(@cur_observer, @slowest, @fastest, @ndirections)
			observerId=CWRU.get_observerId(@cur_observer)
			targetId = CWRU.get_targetId(@cur_target)
			@cur_prefix = "C#{observerId}_F#{targetId}_"
		end
		
		def startNewDirection( 
			@cur_dir = File.join(@path_to_save, @cur_prefix + "D#{@cur_mts_index}")
			return false if File.exists?(@cur_dir)
		end
		
		def nextFrame(view)
			# if all animations are finished or no connection need to be animated, return false
			if @isfinished || @nconnections==0
				return false
			end
			
			
			
			view.camera.set(@cur_eye_position, @cur_target_position, @cur_up)
			
			# save current_image out
			filename=File.join(@cur_export_path, "#{@cur_frame_index}"+".jpg")
			Sketchup.set_status_text("Exporting frame #{@cur_frame_index} to #{filename}")
			begin
				view.write_image(filename, @image_width, @image_height, true, 1.0)
			rescue
				UI.messagebox("Error exporting animation frame.  Check animation parameters and retry.")
				raise
			end
			
			
			# refresh the design window
			view.show_frame()
			
			#update
			@cur_eye_position.transform! @cur_camera_tranform
			@cur_up.transform! @cur_camera_tranform
			@cur_target_position.transfrom! @cur_target_tranform
			
			
			if @cur_frame_index == @nframes-1
				# finish render one sequence
				
				# reset camera position
				@cur_eye_position = @cur_org_eye_position
				@cur_up = @cur_org_up
				@cur_target_position = @cur_org_target_position
				
				# try to update
			end
			
			@cur_up.tranformation =  @cur_mts[@cur_mts_index] * @cur_up.transformation
			eye_position = CWRU.get_eye_position(@cur_observer)
			target_position = CWRU.get_target_position(@cur_target)
			up = CWRU.get_up(@cur_observer)
			
			if @cur_frame_index == @nframes-1
				observer.transformation = @cur_or
				return false
				# finish render one seqenece
				# put the observer to the original position
				@cur_observer.transformation= @cur_org_tranformation
				
			end
			
			@cur_frame_index +=1
			return true
			
			
			if @cur_frame_index == @nframes-1 && @cur_mts_index == @ndirections - 1 
				
			end
	
			if @cur_frame_index == @nframes-1 && @cur_mts_index == @ndirections - 1 && @cur_connection_index == @nconnections -1
				@isfinished = true
				return true
			end
			
			
			
			
			if @cur_frame_index == @nframes-1 && @cur_mts_index == @ndriections-1
				# begin to render a new pair
				@cur_connection_index += 1
				
				connection 	= @connections[@cur_connection_index]
				observer 	= connection[0]
				target 		= connection[1]
				observerId	= CWRU.get_observerId(observer)
				targetId 	= CWRU.get_targetId(target)
				
				@cur_mts =  CWRU.generate_random_mts(observer, @slowest, @fastest, @ndirections)
				@cur_prefix = "C#{observerId}_F#{targetId}_"
				@cur_mts_index = 0
			
			elsif @cur_frame_index == @nframes-1 # && @cur_mts_index < @ndriections-1 
				
				# finish render in one direction and begin to render in a new direction
				@cur_mts_index += 1
				@cur_export_path = cur_dir = File.join(export_path, "C#{observerId}_F#{targetId}_D#{@cur_mts_index}")
				
				if File.exist?(cur_dir)
					puts "#{cur_dir} exists!"
					next
				end
				
			elsif  @cur_frame_index < @nframes-1 && @cur_mts_index < @ndirections - 1 
				
				
				
			end
			
			# update current frame index and current mts index
			@cur_frame_index = (@cur_frame_index + 1) % @nframes
			@cur_mts_index = (@cur_mts_index + 1) % @ndirections
			
			
			if @cur_frame_index == @nframe-1
				@cur_mts_index = 
			end
			
		
			cur_transform = observer.transformation	
			observer.transformation= @mt * cur_transform
			
		
		
		
			return true
		end
		
		
		def export_one_sequence(view, observer, target, mt, nframe, image_width, image_height, fov, export_path, prefix="")
			torg=observer.transformation
			target_position = CWRU.get_target_position(target)
		
			#loop for each frame
			(0...nframe).each{ |frameId|
				cur_transform = observer.transformation	
				observer.transformation= mt * cur_transform
			
				up = CWRU.get_up(observer)
				eye_position = CWRU.get_eye_position(observer)
				view.camera.set(eye_position, target_position, up)
			
				# save image out
				filename=File.join(export_path, prefix + "#{frameId}"+".jpg")
				Sketchup.set_status_text("Exporting frame #{frameId} to #{filename}")
				begin
					view.write_image(filename, image_width, image_height, true, 1.0)
				rescue
					UI.messagebox("Error exporting animation frame.  Check animation parameters and retry.")
					raise
				end
			}
			puts observer.transformation.to_a
		
			observer.transformation= torg
		end
	end
end