class DelayedPaperclipJob < Struct.new(:instance_klass, :instance_id, :attachment_name)
  def perform
    process_job do
			begin
	      instance.send(attachment_name).reprocess!
	      instance.send("#{attachment_name}_processed!")
			rescue Exception => e
				log = Logger.new(STDOUT)
				log.debug e.message
				e.backtrace.each do |i|
					log.debug i
				end				
			end
    end
  end
  
  private
  def instance
    @instance ||= instance_klass.constantize.get(instance_id)
  end
  
  def process_job
    instance.send(attachment_name).job_is_processing = true
    yield
    instance.send(attachment_name).job_is_processing = false    
  end
end
