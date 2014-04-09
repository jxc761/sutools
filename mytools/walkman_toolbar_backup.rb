# MyTool by  Jing Chen

require "sketchup.rb"
require "#{File.dirname(__FILE__)}/mytools/visualize_camera.rb"
require "#{File.dirname(__FILE__)}/mytools/place_observer_tool.rb"
require "#{File.dirname(__FILE__)}/mytools/select_target_tool.rb"

module CWalkmanToolbar
	
	class CPlaceObserverTool
	
		def activate
			view.invalidata
		end
	
		def deactivate(view)
			view.invalidate 
		end
	
		def onLButtonDoubleClick(flags, x, y, view)
			status = Sketchup.active_model.start_operation('place observer into the scene', true)
			place_observer(x, y, view)
			view.invalidate 
			status = Sketchup.active_model.commit_operation
		
		end
	
		def place_observer(x, y, view)
			entities = Sketchup.active_model.entities
			transformation = nil
			inputpoint = view.inputpoint x,y
			origin 	= inputpoint.position
			normal = Geom::Vector3d.new [0, 0, 1]
			if inputpoint.face != nil 
				 normal = face.normal
			 end
		
			transformation = Geom::Transformation.new(origin, normal)
			if @observer==nil
				@observer = entities.add_instance(@observer_definition, transformation)
			else
				@observer.transformation=transformation
			end
		end
	end
	
	class CMoverObserverTool
		def activate
			view.invalidata
		end
	
		def deactivate(view)
			view.invalidate 
		end
	
	    def onKeyDown(key, repeat, flags, view)
			 move_observer(key, repeat, flags, view)
	    end
	end
	
	
	class  CShowWatchedTool
		def activate
			view.invalidata
		end
	
		def deactivate(view)
			view.invalidate 
		end
		
	    def onKeyDown(key, repeat, flags, view)
			 move_observer(key, repeat, flags, view)
			 update(view)
	    end
	end

	
	
	def CWalkmanToolbar.move_observer(key, repeat, flags, view)

		t_org = @observer.transformation
		v0 = Geom::Vector3d.new 0,0,0
		case key
		when VK_LEFT
			tranform = Geom::Transformation.translation t_org.xaxis
		when VK_RIGHT
			v = v0- t_org.xaxis
			tranform = Geom::Transformation.translation v
		when VK_UP
			v = v0 - t_org.yaxis 
			tranform = Geom::Transformation.translation v
		when VK_DOWN
			tranform = Geom::Transformation.translation t_org.yaxis
		else
			tranform = Geom::Transformation.translation
		end
		@observer.transformation= tranform * t_org
	end
	
	def CWalkmanToolbar.update(view)
		camera=view.camera
		camera.set(get_eye(), get_target(), get_up())
	end
	
	
	def CWalkmanToolbar.get_eye()
		if @observer == nil
			return nil
		end
		
		t = @observer.transformation
		ve = t.zaxis.clone
		ve.length= 1.7.m
		eye = t.origin + ve
		return eye
	end

	def CWalkmanToolbar.get_up()
		if @observer == nil
			return nil
		end
		return @observer.transformation.zaxis
	end
	
	def CWalkmanToolbar.get_target()
		return @target.position
	end
	
	
	def CWalkmanToolbar.draw(view)
		
		if @observer!=nil && @target!=nil
			view.set_color_from_line(get_eye(),  get_target())
			view.draw_line(get_eye(),  get_target())
		end	
		
		if @target!=nil
			@target.draw(view)
		end
		
	end
	
	
	@pick_target_tool = CPickTargetTool.new
	@place_observer_tool = CPlaceObserverTool.new
	@move_observer_tool = CMoverObserverTool.new
	@show_watched_tool = CShowWatchedTool.new

	@observer=nil
	@target=nil
	
	@observer_definition=nil
	
	definitions = Sketchup.active_model.definitions
	@observer_definition = definitions["cwru_observer"]
	if @observer_definition == nil
		@observer_definition =definitions.load "#{File.dirname(__FILE__)}/skp/cwru_observer.skp"
	end
	
	
	@cmd_pick_target = UI::Command.new("pick_target") { 
    	Sketchup.active_model.select_tool(@pick_target_tool)  
  	}
	@cmd_pick_target.small_icon = "./MyTools/icons/target_16.png"
	@cmd_pick_target.large_icon = "./MyTools/icons/target_24.png"
	@cmd_pick_target.menu_text = "Pick target"
	@cmd_pick_target.tooltip = "Pick a target"
	@cmd_pick_target.status_bar_text = "double click"
 	

	@cmd_place_observer = UI::Command.new("place_observer") {
		Sketchup.active_model.select_too(@place_observer_tool)
	}
	@cmd_place_observer.small_icon = "place_observer_16.png"
	@cmd_place_observer.large_icon = "place_observer_24.png"
	@cmd_place_observer.menu_text = "Place observer"
	@cmd_place_observer.tooltip = "Place an observer into the scene"
	@cmd_place_observer.status_bar_text = "double click"
	
	
	@cmd_move_observer = UI::Command.new("move_observer") {
		Sketchup.active_model.select_too(@move_observer_tool)
	}
	
	@cmd_move_observer.small_icon = "move_observer_16.png"
	@cmd_move_observer.large_icon = "move_observer_24.png"
	@cmd_move_observer.menu_text = "move observer"
	@cmd_move_observer.tooltip = "move the observer"
	@cmd_move_observer.status_bar_text = "left/right/down/up:move the observer"
	@cmd_move_observer.set_validation_proc {
	    if @observer == nil 
			MF_GRAYED
		else
	            MF_ENABLED
	    end
	}
	
	
	@cmd_show_watched = UI::Command.new("show_watched") {
		Sketchup.active_model.select_too(@show_watched_tool)
	}
	@cmd_show_watched.small_icon = "show_watched_16.png"
	@cmd_show_watched.large_icon = "show_watched24.png"
	@cmd_show_watched.menu_text = "look through the observer"
	@cmd_show_watched.tooltip = "look through the observer"
	@cmd_show_watched.status_bar_text = "left/right/down/up:move the observer"
	@cmd_show_watched.set_validation_proc {
		    if @observer == nil || @target==nil 
					MF_GRAYED
			else
		            MF_ENABLED
		    end
	}
	
	walkman_toolbar = UI::Toolbar.new("walkman")
	
    walkman_toolbar.add_item(@cmd_pick_target)
	walkman_toolbar.add_item(@cmd_place_observer)
	walkman_toolbar.add_item(@cmd_move_observer)
	walkman_toolbar.add_item(@cmd_show_watched)
	

end

############################

if not file_loaded?(__FILE__ )
end

file_loaded(__FILE__ )