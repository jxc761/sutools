require "sketchup"

# load("/Users/Jing/Library/Application Support/SketchUp 2013/SketchUp/Plugins/mytools/walkman.rb")
module CWRU
	
	
	class CEntityObserver < Sketchup::EntityObserver
		  def onEraseEntity(entity)
			  puts "All related connections will be deleted"
			  if entity.model==nil
				  puts "entity.model==nil"
			  end
			  CWRU.clear_connections(Sketchup.active_model)
		  end
	 end
	 
=begin
	class CTargetObserver < Sketchup::EntityObserver
		  def onEraseEntity(entity)
			  puts "All target related connections will be deleted"
			  if entity.model==nil
				  puts "entity.model==nil"
			  end
			  connections = CWRU.get_connections(Sketchup.active_model)
			  targetId = CWRU.get_targetId(entity)
			  connections =CWRU.delete_target_related_connections(connections, targetId)
			  CWRU.save_connections(Sketchup.active_model, connections)
		  end
	 end
	 
 	class CObserverObserver < Sketchup::EntityObserver
 		  def onEraseEntity(entity)
			 puts "All observer related connections will be deleted"
		 	 if entity.model==nil
			  	puts "entity.model==nil"
		 	 end
			 connections = CWRU.get_connections(Sketchup.active_model)
			 observerId = CWRU.get_observerId(entity)
			 connections = CWRU.delete_observer_related_connections(connections, observerId)
			 CWRU.save_connections(Sketchup.active_model, connections)
 		  end
 	 end
=end
	 ###########################################
	 # target
	 ######################################
	def CWRU.get_target_definition(model)
		target_definition = model.definitions["cwru_target"]
		if target_definition == nil
			target_definition =Sketchup.active_model.definitions.load TARGET_PATH
		end
		
		return target_definition
	end

	
 	def CWRU.find_target(model, targetId)
 		target_definition = model.definitions["cwru_target"]
 		if target_definition == nil
 			return nil
 		end
		
 		instances = target_definition.instances
		
 		instances.each{ |inst|
 			id = inst.get_attribute "cwru_walkman", "id", Time.now.to_i.to_s
			
 			if id == targetId
 				return inst
 			end
 		}
 		return nil
 	end
	
	
 	def CWRU.get_target_position(target)
 		t = target.transformation
 		return t.origin
 	end
	
 	def CWRU.is_target(ent)
 		if ent.typename == "ComponentInstance" && get_target_definition(ent.model).name == ent.definition.name
 			return true
 		else
 			return false
 		end
 	end
	
 	def CWRU.new_target(model, transformation)
		
 		definition = get_target_definition(model)
 		target = model.entities.add_instance(definition, transformation)
 		set_targetId(target, Time.now.to_i.to_s)
 		target.add_observer(CEntityObserver.new)
		return target
 	end


	#####
	#observer
	#####
 	def CWRU.new_observer(model, transformation)
 		definition = get_observer_definition(model)
 		observer = model.entities.add_instance(definition, transformation)
 		set_observerId(observer, Time.now.to_i.to_s)
 		observer.add_observer(CEntityObserver.new)
		return observer
 	end
	
	def CWRU.find_observer(model, observerId)
		observer_definition = model.definitions["cwru_observer"]
		if observer_definition == nil
			return nil
		end
		
		instances = observer_definition.instances
		instances.each{ |inst|
			id = inst.get_attribute "cwru_walkman", "id", Time.now.to_i.to_s	
			if id == observerId
				return inst
			end
		}
		return nil
	end
	
	def CWRU.get_observer_definition(model)
		observer_definition = model.definitions["cwru_observer"]
		if observer_definition == nil
			observer_definition =Sketchup.active_model.definitions.load OBSERVRE_PATH
		end
		
		return observer_definition
	end
	
	def CWRU.get_eye_position(observer)
		if observer == nil
			return nil
		end
		
		t = observer.transformation
		ve = t.zaxis.clone
		ve.length= 1.7.m
		eye = t.origin + ve
		return eye
	end

	def CWRU.get_up(observer)
		if observer == nil
			return nil
		end
		return observer.transformation.zaxis
	end
	
	
	def CWRU.is_observer(ent)
		if ent.typename == "ComponentInstance" && get_observer_definition(ent.model).name == ent.definition.name
			return true
		else
			return false
		end
	end

  
	
	##########
	# connection
	###########
	
	def CWRU.get_connections(model)
		
		connections = Array.new
		attr = model.get_attribute('cwru_walkman', 'connections', "")
		substrs=attr.split("|")
		
		substrs.each{|substr|
			next if substr== ""
			ids = substr.split(',')
			observer = find_observer(model, ids[0])
			target = find_target(model, ids[1])
			connections << [observer, target]
		}
		
		return connections

	end
	
	def CWRU.save_connections(model, connections)
		attr = ""
		if connections != nil
			connections.each{|connection|
				observer = connection[0]
				target = connection[1]	
				obsId = get_observerId(observer)
				targetId = get_targetId(target)
				attr << obsId << "," << targetId << "|"
			}
		end
		
		model.set_attribute('cwru_walkman', 'connections', attr)
		
	end
	
	def CWRU.get_observer_related_connection(connections, observerId)
		new_connections = Array.new
		connections.each{ |connection|
			id = get_observerId(connection[0])
			if id == observerId
				new_connections << connection
			end
		}
		return new_connections
	end
	
	def CWRU.clear_connections(model)
		connections = CWRU.get_connections(Sketchup.active_model)
		new_connections = Array.new
		connections.each{ |connection|
			if connection[0]!=nil && connection[1] != nil
				new_connections << connection
			end
		}
		save_connections(model, new_connections)
	end
	
=begin
	def CWRU.delete_target_related_connections(connections, targetId)		
		
		new_connections = Array.new
		connections.each{ |connection|
			id = get_targetId(connection[1])
			if id != targetId
				new_connections << connection
			end
		}
		connections = new_connections
		return connections
	end
	
	
	def CWRU.delete_observer_related_connections(connections, observerId)		
		
		new_connections = Array.new
		connections.each{ |connection|
			id = get_observerId(connection[0])
			if id != observerId
				new_connections << connection
			end
		}
		connections = new_connections
		return connections
	end
=end
	def CWRU.get_observerId (observer)
		return observer.get_attribute("cwru_walkman", "id",Time.now.to_i.to_s)
	end
	
	def CWRU.get_targetId(target)
		return target.get_attribute("cwru_walkman", "id",Time.now.to_i.to_s)
	end
	
	def CWRU.set_observerId(observer, id)
		observer.set_attribute("cwru_walkman", "id", id)
	end
	
	def CWRU.set_targetId(target, id)
		target.set_attribute("cwru_walkman", "id", id)
	end
	

end