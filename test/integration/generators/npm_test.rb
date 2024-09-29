# frozen_string_literal: true

require_relative "test_case"

class Nextgen::Generators::NpmTest < Nextgen::Generators::TestCase
  destination File.join(Dir.tmpdir, "test_#{SecureRandom.hex(8)}")
  setup :prepare_destination

  test "removes yarn.lock and generates a package-json.lock" do
    Dir.chdir(destination_root) do
      File.write("package.json", "{}\n")
      FileUtils.touch("yarn.lock")
      FileUtils.touch("README.md")
    end

    apply_generator

    assert_no_file "yarn.lock"
    assert_file "package-lock.json"
  end

  test "removes mentions of yarn from README.md" do
    Dir.chdir(destination_root) do
      File.write("package.json", "{}\n")
      File.write("README.md", <<~MD)
        - Node 18 (LTS) or newer
        - Yarn 1.x (classic)

        brew install node
        brew install yarn
      MD
    end

    apply_generator

    assert_file "README.md", <<~EXPECTED
      - Node 18 (LTS) or newer

      brew install node
    EXPECTED
  end

  test "removes mentions of yarn from Procfile.dev" do
    Dir.chdir(destination_root) do
      File.write("package.json", "{}\n")
      FileUtils.touch("README.md")
      File.write("Procfile.dev", <<~PROCFILE)
        web: env RUBY_DEBUG_OPEN=true bin/rails server
        js: yarn build --watch
      PROCFILE
    end

    apply_generator

    assert_file "Procfile.dev", <<~EXPECTED
      web: env RUBY_DEBUG_OPEN=true bin/rails server
      js: npm run build -- --watch
    EXPECTED
  end

  test "removes mentions of yarn from Dockerfile" do
    Dir.chdir(destination_root) do
      File.write("package.json", "{}\n")
      FileUtils.touch("README.md")
      File.write("Dockerfile", <<~'DOCKER')
        # Install JavaScript dependencies
        ARG NODE_VERSION=20.17.0
        ARG YARN_VERSION=1.22.22
        ENV PATH=/usr/local/node/bin:$PATH
        RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
            /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
            npm install -g yarn@$YARN_VERSION && \
            rm -rf /tmp/node-build-master

        # Install node modules
        COPY package.json yarn.lock ./
        RUN yarn install --frozen-lockfile
      DOCKER
    end

    apply_generator

    assert_file "Dockerfile", <<~'EXPECTED'
      # Install JavaScript dependencies
      ARG NODE_VERSION=20.17.0
      ENV PATH=/usr/local/node/bin:$PATH
      RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
          /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
          rm -rf /tmp/node-build-master

      # Install node modules
      COPY package.json package-lock.json ./
      RUN npm ci
    EXPECTED
  end
end
