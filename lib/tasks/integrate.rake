APP = Rails.application.class.parent_name.underscore

def sh_with_clean_env(cmd)
  Bundler.with_clean_env do
    sh "#{cmd}"
  end
end

desc 'Run all integration process: pull, migration, ' +
  'specs with coverage, push and deploy (with lock/unlock strategy)'
task integrate:
  [
   'integration:git:status_check',
   'log:clear',
   'tmp:clear',
   'integration:git:pull',
   'integration:rails:bundle_install',
   'db:drop',
   'db:create',
   'db:migrate',
   'db:seed',
   'db:test:prepare',
   'integration:test',
   'integration:git:master_branch_check',
   'integration:git:promote_master_to_staging',
   'integration:git:push',
   'integration:lock',
   'integration:deploy',
   'integration:unlock'
  ]

desc 'Promote stage environment to production, ' +
     'checks coverage and tests'
task 'promote_staging_to_production' do
  [
   'integration:git:status_check',
   'integration:git:pull',
   'integration:git:master_branch_check',
   'integration:git:promote_staging_to_production',
   'integration:git:push',
   'integration:db:backup',
   'integration:lock',
   'integration:deploy',
   'integration:unlock'
  ].each do |task|
    Rake::Task[task].invoke('production')
  end
end

namespace :integration do
  task 'test' do
    system('rake test RAILS_ENV=test')
    raise 'tests failed' unless $?.success?
  end

  task :lock, [:app_env] do |t, args|
    args.with_defaults(app_env: 'staging')

    app_env = args[:app_env]
    app_name = "#{APP}-#{app_env}"


    user = `whoami`.chomp
    sh_with_clean_env "heroku config:add INTEGRATING_BY=#{user} --app #{app_name}"
  end

  task :unlock, [:app_env] do |t, args|
    args.with_defaults(app_env: 'staging')

    app_env = args[:app_env]
    app_name = "#{APP}-#{app_env}"

    sh_with_clean_env "heroku config:remove INTEGRATING_BY --app #{app_name}"
  end

  task 'deploy', [:app_env] do |t, args|
    args.with_defaults(app_env: 'staging')

    app_env = args[:app_env]
    app_name = "#{APP}-#{app_env}"

    puts "-----> Pushing #{app_env} to #{app_name}..."
    sh_with_clean_env "git push git@heroku.com:#{app_name}.git #{app_env}:master"

    puts "-----> Migrating..."
    sh_with_clean_env "heroku run rake db:migrate --app #{app_name}"

    puts "-----> Seeding..."
    sh_with_clean_env "heroku run rake db:seed --app #{app_name}"

    puts "-----> Restarting..."
    sh_with_clean_env "heroku restart --app #{app_name}"
  end

  namespace :db do
    task :backup, [:app_env] do |t, args|
      args.with_defaults(app_env: 'staging')

      app_env = args[:app_env]
      app_name = "#{APP}-#{app_env}"

      # https://devcenter.heroku.com/articles/pgbackups
      puts "-----> Backup #{app_env} database..."
      sh_with_clean_env "heroku pg:backups capture --app #{app_name}"
    end

  end

  namespace :rails do
    task :bundle_install do
      `bin/bundle install`
    end
  end

  namespace :git do
    task :status_check do
      result = `git status`
      if result.include?('Untracked files:') ||
          result.include?('unmerged:') ||
          result.include?('modified:')
        puts result
        exit
      end
    end

    task 'master_branch_check' do
      cmd = []
      cmd << "git branch --color=never" # list branches avoiding color
                                        #   control characters
      cmd << "grep '^\*'"               # current branch is identified by '*'
      cmd << "cut -d' ' -f2"            # split by space, take branch name

      branch = `#{cmd.join('|')}`.chomp

      # Don't use == because git uses bash color escape sequences
      unless branch == 'master'
        puts "You are at branch <#{branch}>"
        puts "Integration deploy runs only from <master> branch," +
          " please merge <#{branch}> into <master> and" +
          " run integration proccess from there."

        exit
      end
    end

    task :pull do
      sh 'git pull --rebase'
    end

    task :push do
      sh 'git push'
    end

    task :promote_master_to_staging do
      sh "git checkout staging"
      sh 'git pull --rebase'
      sh "git rebase master"
      sh 'git push origin staging'
      sh "git checkout master"
    end

    task :promote_staging_to_production do
      sh "git checkout production"
      sh 'git pull --rebase'
      sh "git rebase staging"
      sh 'git push origin production'
      sh "git checkout master"
    end
  end
end
