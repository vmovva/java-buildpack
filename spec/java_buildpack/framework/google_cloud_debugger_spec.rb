# Encoding: utf-8
# Cloud Foundry Java Buildpack
# Copyright 2013-2017 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'spec_helper'
require 'component_helper'
require 'java_buildpack/framework/google_cloud_debugger'

describe JavaBuildpack::Framework::GoogleCloudDebugger do
  include_context 'component_helper'

  it 'does not detect without google-cloud-debugger-n/a service' do
    expect(component.detect).to be_nil
  end

  context do

    before do
      allow(services).to receive(:one_service?).with(/google-cloud-debugger/, 'module', 'version').and_return(true)

      allow(services).to receive(:find_service).and_return(
        'credentials' => {
          'module'  => 'test-module',
          'version' => 'test-version'
        }
      )
    end

    it 'detects with google-cloud-debugger-c-n/a service' do
      expect(component.detect).to eq("google-cloud-debugger=#{version}")
    end

    it 'unpacks the google cloud debugger tar',
       cache_fixture: 'stub-google-cloud-debugger.tar.gz' do

      component.compile

      expect(sandbox + 'cdbg_java_agent.so').to exist
    end

    it 'updates JAVA_OPTS' do
      component.release
      expect(java_opts).to include('-agentpath:$PWD/.java-buildpack/google_cloud_debugger/cdbg_java_agent.so')
      expect(java_opts).to include('-Dcom.google.cdbg.module=test-module')
      expect(java_opts).to include('-Dcom.google.cdbg.version=test-version')
    end

  end

end
