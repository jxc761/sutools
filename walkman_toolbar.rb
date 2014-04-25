require "sketchup"
require "#{File.dirname(__FILE__)}/mytools/walkman_tools.rb"
require "#{File.dirname(__FILE__)}/mytools/export_animation.rb"
require "#{File.dirname(__FILE__)}/mytools/walkman_random_walk_setting.rb"
require "#{File.dirname(__FILE__)}/mytools/walkman_visualization.rb"
require "#{File.dirname(__FILE__)}/mytools/walkman_animation.rb"


# load("/Users/Jing/Library/Application Support/SketchUp 2013/SketchUp/Plugins/walkman_toolbar.rb")



module CWRU
	def CWRU.show_all_info
		show_all_observers
		show_all_targets
		redraw_links
		redraw_random_walk_trajectories
	end

	def CWRU.hide_all_info
		hide_all_observers
		hide_all_targets
		undraw_links
		undraw_random_walk_trajectories
	end

	def CWRU.export_images()
		#hide_all_observers
		#hide_all_targets
		#undraw_links
		
		walk_opts = CWRU.random_walk_setting()
		animation_opts = CWRU.animate_setting()
		if walk_opts == nil || animation_opts == nil
			return
		end
		
		model = Sketchup.active_model
		view = model.active_view
		
		CWRU.set_random_walk_setting(model, walk_opts)
		CWRU.set_animation_setting(model, animation_opts)
		CWRU.export_random_walk_animations(model, view, walk_opts, animation_opts)
		
		#show_all_observers
		#show_all_targets
		
	end

	
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
	cmd_look_through.menu_text = "look through"
	cmd_look_through.tooltip = "look_through"
	cmd_look_through.status_bar_text = "Double click"
	
	
	
	cmd_export = UI::Command.new("export_random_walk_animation ") {export_images
		
	}
	cmd_export.small_icon = "./MyTools/icons/export_images_16.png"
	cmd_export.large_icon = "./MyTools/icons/export_images_24.png"
	cmd_export.menu_text = "export random walking animation"
	cmd_export.tooltip = "export random walking animation"
	cmd_export.status_bar_text = "export random walking animation"
	
	
	
	walkman_toolbar = UI::Toolbar.new("walkman")	
    walkman_toolbar.add_item(cmd_add_observer)
	walkman_toolbar.add_item(cmd_add_target)
	walkman_toolbar.add_item(cmd_edit_connection)
	walkman_toolbar.add_item(cmd_move_observer)
	walkman_toolbar.add_item(cmd_look_through)
	walkman_toolbar.add_item(cmd_export)
	
	
	Sketchup.send_action("showRubyPanel:")
	
	UI.add_context_menu_handler do |menu|

		# Add an item to the context menu
		menu.add_separator
		menu.add_item("export all animations") { CWRU.export_all_animations}
		item=menu.add_item("export selection animations") { CWRU.export_selection_animations}
		menu.set_validation_proc(item){CWRU.export_selection_animations_validation}
	end
	
	
	
	####
	# add items to view menu
	####

	
	menu =UI.menu("View")
	menu.add_separator
	submenu = menu.add_submenu("walkman")
	item = submenu.add_item("Show all"){ 			 	CWRU.show_all_info 				}
	item = submenu.add_item("Hide all"){ 				CWRU.hide_all_info				}
	item = submenu.add_item("Show all cameras"){		CWRU.show_all_observers		}
	item = submenu.add_item("Hide all cameras"){		CWRU.hide_all_observers		}
	item = submenu.add_item("Show all focal points"){	CWRU.show_all_targets		}
	item = submenu.add_item("Hidel all focal points"){	CWRU.hide_all_targets		}
	item = submenu.add_item("Redraw all links"){		CWRU.redraw_links 			}
	item = submenu.add_item("Undraw all links"){		CWRU.undraw_links			}
	item = submenu.add_item("Redraw trajectories"){		CWRU.redraw_random_walk_trajectories	}
	item = submenu.add_item("Undraw trajectories"){		CWRU.undraw_random_walk_trajectories	}
	
	

end

file_loaded( __FILE__ )