# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"

# This filter plugin allows you extract Pod, Namespace, etc from kubernetes.
# The way this filter works is very simple. It looks at an event field which
# contains full path to kubelet created symlinks to docker container logs and
# extracts useful information from a symlink name. No access to Kubernetes API
# is required.
class LogStash::Filters::Kubernetes < LogStash::Filters::Base

  # This is how you configure this filter from your Logstash config.
  #
  # Example:
  # [source,ruby]
  # input {
  #   file {
  #     # Path to kubelet symlinks to docker logs, by default, symlinks look like
  #     # /var/log/containers/*.log --> /var/lib/docker/containers/*/*-json.log
  #     path => "/var/log/containers/*.log"
  #   }
  # }
  #
  # filter {
  #   kubernetes {
  #     source => "path"
  #     target => "kubernetes"
  #   }
  # }
  #
  config_name "kubernetes"

  # The source field name which contains full path to kubelet log file.
  config :source, :validate => :string, :default => "path"

  # The target field name to write event kubernetes metadata.
  config :target, :validate => :string, :default => "kubernetes"


  public
  def register
    # Nothing to do
  end # def register

  public
  def filter(event)

    if @source and event[@source]
      parts = event[@source].split(File::SEPARATOR).last.gsub(/.log$/, '').split('_')

      # We do not care about empty POD log files
      if parts.length != 3 || parts[2].start_with?('POD-')
        return
      else
        kubernetes = {}
        kubernetes['replication_controller'] = parts[0].gsub(/-[0-9a-z]*$/, '')
        kubernetes['pod'] = parts[0]
        kubernetes['namespace'] = parts[1]
        kubernetes['container_name'] = parts[2].gsub(/-[0-9a-z]*$/, '')
        kubernetes['container_id'] = parts[2].split('-').last

        event[@target] = kubernetes
      end
    end

    # filter_matched should go in the last line of our successful code
    filter_matched(event)
  end # def filter
end # class LogStash::Filters::Kubernetes
