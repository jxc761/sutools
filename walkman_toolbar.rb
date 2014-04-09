require "sketchup"
require "#{File.dirname(__FILE__)}/mytools/walkman_tools.rb"
require "#{File.dirname(__FILE__)}/mytools/walkman.rb"

# load("/Users/Jing/Library/Application Support/SketchUp 2013/SketchUp/Plugins/walkman_toolbar.rb")

def set_walkman_from_instance
	selection = Sketchup.active_model.selection
	ret = CWalkman.from_inst(selection[0])
	
	case ret
	when 0
		UI.messagebox("Not a vaild observer")
	when 1
		UI.messagebox("observer has been updated, but the target has not")
	when 2
		UI.messagebox("succcessful")
	end
	Sketchup.active_model.select_tool(CMoverObserverTool.new)
end


def check_is_walkman
	
	if Sketchup.active_model.selection.count != 1
		
		MF_GRAYED
	else
		inst = Sketchup.active_model.selection[0]
		if CWalkman.check(inst) == true
			MF_ENABLED
		else
			MF_GRAYED
		end
	end	
end





def check_is_observer
	if Sketchup.active_model.selection.count != 1
		MF_GRAYED
	else
		inst = Sketchup.active_model.selection[0]
		if CWalkman.observer == inst
			MF_ENABLED
		else
			MF_GRAYED
		end
	end
end

if not file_loaded?(__FILE__ )
	
	cmd_pick_target = UI::Command.new("pick_target") { 
    	Sketchup.active_model.select_tool(CPickTargetTool.new)  
  	}
	cmd_pick_target.small_icon = "./MyTools/icons/target_16.png"
	cmd_pick_target.large_icon = "./MyTools/icons/target_24.png"
	cmd_pick_target.menu_text = "Pick target"
	cmd_pick_target.tooltip = "Pick a target"
	cmd_pick_target.status_bar_text = "double click"
 	

	cmd_place_observer = UI::Command.new("place_observer") {
		Sketchup.active_model.select_tool(CPlaceObserverTool.new)
	}
	cmd_place_observer.small_icon = "./MyTools/icons/place_observer_16.png"
	cmd_place_observer.large_icon = "./MyTools/icons/place_observer_24.png"
	cmd_place_observer.menu_text = "Place observer"
	cmd_place_observer.tooltip = "Place an observer into the scene"
	cmd_place_observer.status_bar_text = "double click"
	
	
	cmd_move_observer = UI::Command.new("move_observer") {
		Sketchup.active_model.select_tool(CMoverObserverTool.new)
	}
	
	cmd_move_observer.small_icon = "./MyTools/icons/move_observer_16.png"
	cmd_move_observer.large_icon = "./MyTools/icons/move_observer_24.png"
	cmd_move_observer.menu_text = "move observer"
	cmd_move_observer.tooltip = "move the observer"
	cmd_move_observer.status_bar_text = "left/right/down/up:move the observer"
	cmd_move_observer.set_validation_proc {
	    if CWalkman.observer == nil 
			MF_GRAYED
		else
	            MF_ENABLED
	    end
	}
	
	
	cmd_show_watched = UI::Command.new("show_watched") {
		Sketchup.active_model.select_tool(CShowWatchedTool.new)
	}
	cmd_show_watched.small_icon = "./MyTools/icons/show_watched_16.png"
	cmd_show_watched.large_icon = "./MyTools/icons/show_watched_24.png"
	cmd_show_watched.menu_text = "look through the observer"
	cmd_show_watched.tooltip = "look through the observer"
	cmd_show_watched.status_bar_text = "left/right/down/up:move the observer"
	cmd_show_watched.set_validation_proc {
		    if  CWalkman.observer == nil ||  CWalkman.target==nil 
					MF_GRAYED
			else
		            MF_ENABLED
		    end
	}
	
	walkman_toolbar = UI::Toolbar.new("walkman")
    walkman_toolbar.add_item(cmd_pick_target)
	walkman_toolbar.add_item(cmd_place_observer)
	walkman_toolbar.add_item(cmd_move_observer)
	walkman_toolbar.add_item(cmd_show_watched)
	
	
	
	UI.add_context_menu_handler do |menu|
		item=menu.add_item("set as the active observer") {set_walkman_from_instance}
		menu.set_validation_proc(item){check_is_walkman}
		item=menu.add_item("deactivate"){
			CWalkman.clear()
		}
		menu.set_validation_proc(item){check_is_observer}
	end
	
############################

end

file_loaded(__FILE__ )