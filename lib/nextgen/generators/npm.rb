# frozen_string_literal: true

remove_file "yarn.lock"
run! "npm install --fund=false --audit=false"

gsub_file "README.md", "\n- Yarn 1.x (classic)", ""
gsub_file "README.md", "\nbrew install yarn", ""

gsub_file "Procfile.dev", "yarn build", "npm run build --" if File.exist?("Procfile.dev")

if File.exist?("Dockerfile")
  gsub_file "Dockerfile", /^\s*ARG YARN_VERSION.*\n/, ""
  gsub_file "Dockerfile", /^\s*npm install -g yarn.*\n/, ""
  gsub_file "Dockerfile", "yarn.lock", "package-lock.json"
  gsub_file "Dockerfile", /RUN yarn install.*/, "RUN npm ci"
end
