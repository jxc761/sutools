class CEntityObserver < Sketchup::EntityObserver
	  def onEraseEntity(entity)
		  if is_target(entity)
			  connections = get_connections(entity.model)
			  targetId = get_targetId(entity)
			  delete_target_related_connections(connections, targetId)
		  end
		  
		  if is_observer(entity)
			 connections = get_connections(entity.model)
			 observerId = get_observerId(entity)
			 delete_target_related_connections(connections, observerId)
		  end
	  end
 end