require 'spec_helper'
require "logstash/filters/kubernetes"

describe LogStash::Filters::Kubernetes do
  describe "Split path into kubernetes key-value pairs." do
    let(:config) do <<-CONFIG
      filter {
        kubernetes {
          source => "path"
        }
      }
    CONFIG
    end

    sample("path" => "/var/log/containers/kube-dns-v9-6mnxk_default_skydns-47d3a3bfb112dbd2fd6e255e1e3d9eb91a10b62342e620e4917e2f5e24398507.log") do
      insist { subject["kubernetes"] } == {"replication_controller"=>"kube-dns-v9", "pod"=>"kube-dns-v9-6mnxk", "namespace"=>"default", "container_name"=>"skydns", "container_id"=>"47d3a3bfb112dbd2fd6e255e1e3d9eb91a10b62342e620e4917e2f5e24398507"}
    end
  end
end

describe LogStash::Filters::Kubernetes do
  describe "Set target field name." do
    let(:config) do <<-CONFIG
      filter {
        kubernetes {
          source => "path"
          target => "foobar"
        }
      }
    CONFIG
    end

    sample("path" => "/var/log/containers/kube-dns-v9-6mnxk_default_skydns-47d3a3bfb112dbd2fd6e255e1e3d9eb91a10b62342e620e4917e2f5e24398507.log") do
      insist { subject["foobar"] } == {"replication_controller"=>"kube-dns-v9", "pod"=>"kube-dns-v9-6mnxk", "namespace"=>"default", "container_name"=>"skydns", "container_id"=>"47d3a3bfb112dbd2fd6e255e1e3d9eb91a10b62342e620e4917e2f5e24398507"}
    end
  end
end

describe LogStash::Filters::Kubernetes do
  describe "Skip parsing empty POD event." do
    let(:config) do <<-CONFIG
      filter {
        kubernetes {
          source => "path"
        }
      }
    CONFIG
    end

    sample("path" => "/var/log/containers/kube-dns-v9-6mnxk_default_POD-eaca2cf56e761c25dc4878d48fbe056402ba01f3f6448650d93f988ec121b8cd.log") do
      insist { subject["kubernetes"] } == nil
    end
  end
end
