require "sketchup"
require "#{File.dirname(__FILE__)}/mytools/walkman_tools.rb"
require "#{File.dirname(__FILE__)}/mytools/export_animation.rb"

# load("/Users/Jing/Library/Application Support/SketchUp 2013/SketchUp/Plugins/walkman_toolbar.rb")
module CWRU
	
	OBSERVRE_PATH = "#{File.dirname(__FILE__)}/MyTools/skp/cwru_observer.skp"
	TARGET_PATH = "#{File.dirname(__FILE__)}/MyTools/skp/cwru_target.skp"
	
	
	cmd_add_observer = UI::Command.new("add_observer") {
		Sketchup.active_model.select_tool(CAddObserverTool.new)
	}
	cmd_add_observer.small_icon = "./MyTools/icons/add_observer_16.png"
	cmd_add_observer.large_icon = "./MyTools/icons/add_observer_24.png"
	cmd_add_observer.menu_text = "add an observer"
	cmd_add_observer.tooltip = "add an observer"
	cmd_add_observer.status_bar_text = "Double click"



	cmd_add_target = UI::Command.new("add_target") {
		Sketchup.active_model.select_tool(CAddTargetTool.new)
	}
	cmd_add_target.small_icon = "./MyTools/icons/add_target_16.png"
	cmd_add_target.large_icon = "./MyTools/icons/add_target_24.png"
	cmd_add_target.menu_text = "add an target"
	cmd_add_target.tooltip = "icons/add an target"
	cmd_add_target.status_bar_text = "Double click"
	
	
	cmd_edit_connection = UI::Command.new("connection") {
		Sketchup.active_model.select_tool(CEditConnectionTool.new)
	}
	cmd_edit_connection.small_icon = "./MyTools/icons/edit_connection_16.png"
	cmd_edit_connection.large_icon = "./MyTools/icons/edit_connection_24.png"
	cmd_edit_connection.menu_text = "add/delete connection"
	cmd_edit_connection.tooltip = "add/delete connection"
	cmd_edit_connection.status_bar_text = "Double click"
	
	
	cmd_move_observer = UI::Command.new("connection") {
		Sketchup.active_model.select_tool(CMoveObserverTool.new)
	}
	cmd_move_observer.small_icon = "./MyTools/icons/move_observer_16.png"
	cmd_move_observer.large_icon = "./MyTools/icons/move_observer_24.png"
	cmd_move_observer.menu_text = "move observer"
	cmd_move_observer.tooltip = "move observer"
	cmd_move_observer.status_bar_text = "Double click"
	
	
	cmd_look_through = UI::Command.new("look_through ") {
		Sketchup.active_model.select_tool(CLookThroughTool.new)
	}
	cmd_look_through.small_icon = "./MyTools/icons/look_through_16.png"
	cmd_look_through.large_icon = "./MyTools/icons/look_through_24.png"
	cmd_look_through.menu_text = "look_through"
	cmd_look_through.tooltip = "look_through"
	cmd_look_through.status_bar_text = "Double click"
	
	
	walkman_toolbar = UI::Toolbar.new("walkman")	
    walkman_toolbar.add_item(cmd_add_observer)
	walkman_toolbar.add_item(cmd_add_target)
	walkman_toolbar.add_item(cmd_edit_connection)
	walkman_toolbar.add_item(cmd_move_observer)
	walkman_toolbar.add_item(cmd_look_through)
	
	
	
	Sketchup.send_action("showRubyPanel:")
	
	UI.add_context_menu_handler do |menu|

	# Add an item to the context menu
	menu.add_separator
	menu.add_item("Redraw links") { CWRU.redraw_links}
	menu.add_item("undraw links") { CWRU.undraw_links}
	menu.add_item("export all animations") { CWRU.export_all_animations}
	item=menu.add_item("export selection animations") { CWRU.export_selection_animations}
	menu.set_validation_proc(item){CWRU.export_selection_animations_validation}
	end

end

file_loaded( __FILE__ )