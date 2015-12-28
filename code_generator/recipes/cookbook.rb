
context = ChefDK::Generator.context
cookbook_dir = File.join(context.cookbook_root, context.cookbook_name)
hooks_dir = File.join(cookbook_dir, '/hooks')
chef_omnibus_version = '12.4.1'

# cookbook root dir
directory cookbook_dir

# metadata.rb
template "#{cookbook_dir}/metadata.rb" do
  helpers(ChefDK::Generator::TemplateHelper)
end

# README
template "#{cookbook_dir}/README.md" do
  helpers(ChefDK::Generator::TemplateHelper)
end

# chefignore
cookbook_file "#{cookbook_dir}/chefignore"

# Berks
cookbook_file "#{cookbook_dir}/Berksfile"

# Gemfile
cookbook_file "#{cookbook_dir}/Gemfile"

# Thorfile
cookbook_file "#{cookbook_dir}/Thorfile"

# Guardfile
cookbook_file "#{cookbook_dir}/Guardfile"

# TK
template "#{cookbook_dir}/.kitchen.yml" do
  source 'kitchen.yml.erb'
  variables(chef_omnibus_version: chef_omnibus_version)
  helpers(ChefDK::Generator::TemplateHelper)
end

# rubocop
cookbook_file "#{cookbook_dir}/.rubocop.yml" do
  source 'rubocop.yml'
end

# Recipes

directory "#{cookbook_dir}/recipes"

template "#{cookbook_dir}/recipes/default.rb" do
  source 'default_recipe.rb.erb'
  helpers(ChefDK::Generator::TemplateHelper)
end

# Attributes

directory "#{cookbook_dir}/attributes"

template "#{cookbook_dir}/attributes/default.rb" do
  source 'default_attribute.rb.erb'
  helpers(ChefDK::Generator::TemplateHelper)
end

# Spec

directory "#{cookbook_dir}/spec"
directory "#{cookbook_dir}/spec/default"

cookbook_file "#{cookbook_dir}/spec/spec_helper.rb" do
  source 'spec_helper.rb'
end

# Integration test
directory "#{cookbook_dir}/test"
directory "#{cookbook_dir}/test/integration"
directory "#{cookbook_dir}/test/integration/data_bags"

# Secrets
cookbook_file "#{cookbook_dir}/test/integration/secretfile" do
  source 'secretfile'
end

# Git Hooks dir
directory hooks_dir

# Pre-commit hook
cookbook_file "#{hooks_dir}/pre-commit" do
  source 'hooks/pre-commit'
end

# git
if context.have_git
  unless context.skip_git_init

    execute('initialize-git') do
      command('git init .')
      cwd cookbook_dir
    end

    cookbook_file "#{cookbook_dir}/.gitignore" do
      source 'gitignore'
    end

    link "#{cookbook_dir}/.git/hooks/pre-commit" do
      to "#{hooks_dir}/pre-commit"
      link_type :symbolic
    end

    execute 'update pre-commit execute permissions' do
      command "chmod +x #{cookbook_dir}/.git/hooks/pre-commit"
      action :run
    end
  end
end
