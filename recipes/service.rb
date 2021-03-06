#
# Cookbook:: push-jobs
# Recipe:: service
#
# Author:: Tim Smith <tsmith@chef.io>
# Copyright:: 2013-2016, Chef Software, Inc. <legal@chef.io>
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if platform_family?('windows')
  include_recipe 'push-jobs::service_windows'
elsif node['push_jobs']['init_style'] == 'runit'
  push_jobs_service_runit 'push-jobs' do
    action [:start, :enable]
    subscribes :restart, "template[#{PushJobsHelper.config_path}]"
  end
elsif platform_family?('aix')
  aix_subsystem 'push-jobs-client' do
    program '/opt/push-jobs-client/bin/pushy-client'
    arguments '-l info -L /var/log/chef/push-jobs-client.log -c /etc/chef/push-jobs-client.rb'
    use_signals true
    normal_stop_signal 15
    force_stop_signal 9
    user '0'
    action :create
  end
  push_jobs_service_aix 'push-jobs-client' do
    action [:start]
    subscribes :restart, "template[#{PushJobsHelper.config_path}]"
  end
else
  push_jobs_service 'push-jobs' do
    action [:enable, :start]
    subscribes :restart, "template[#{PushJobsHelper.config_path}]"
  end
end
