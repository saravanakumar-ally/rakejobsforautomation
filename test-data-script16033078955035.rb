#Base script to see test data using rake
def seed_organization(organization)
  Organization.new.tap do |org|
    org.name = organization[:name]
    org.domains.build(name: organization[:domain])
    org.signup_mode=0
    org.save!
  end
end

def seed_billing_plans()
  BillingPlan.create_with(
    name: 'Starter',
    amount: 39,
    usage_quantity: :fixed_amount,
    billing_scheme: :per_unit,
    default: true
  ).find_or_create_by!(code: :starter)
  BillingPlan.create_with(
    name: 'Growth',
    amount: 9,
    usage_quantity: :per_seat,
    billing_scheme: :per_unit,
  ).find_or_create_by!(code: :growth)
  BillingPlan.create_with(
    name: 'Free',
    amount: 0,
    usage_quantity: :fixed_amount,
    billing_scheme: :per_unit,
    trial_period_days: 0
  ).find_or_create_by!(code: :free)
  BillingPlan.create_with(
    name: 'Starter Annual',
    amount: 348, # $29 * 12 months
    usage_quantity: :fixed_amount,
    billing_scheme: :per_unit,
    interval: :year
  ).find_or_create_by!(code: :starter_annual)
  BillingPlan.create_with(
    name: 'Growth Annual',
    amount: 84, # $7 * 12 months
    usage_quantity: :per_seat,
    billing_scheme: :per_unit,
    interval: :year
  ).find_or_create_by!(code: :growth_annual)
  BillingPlan.create_with(
    name: 'Enterprise',
    amount: 14,
    usage_quantity: :per_seat,
    billing_scheme: :per_unit,
  ).find_or_create_by!(code: :enterprise)
  BillingPlan.create_with(
    name: 'Enterprise Annual',
    amount: 132, # $11 * 12
    usage_quantity: :per_seat,
    billing_scheme: :per_unit,
    interval: :year
  ).find_or_create_by!(code: :enterprise_annual)
end

def seed_billing_subscription(bill_subscription)
  BillingSubscription.new do |bill|
    bill.organization_id = bill_subscription[:organization_id]
    bill.billing_name = bill_subscription[:billing_name]
    bill.billing_email = bill_subscription[:billing_email]
    bill.billing_plan_ids = bill_subscription[:billing_plan]
    bill.status = bill_subscription[:status]
    bill.trial_ends_at = Time.now + 14.days
    bill.save!
  end
end

def seed_user(user)
  User.new.tap do |us|
    us.name = user[:name]
    us.email = user[:email]
    us.password = user[:password]
    us.organization_id = user[:organization_id]
    us.skip_confirmation!
    us.save!
  end
end

def seed_team(team)
  Team.new do |tm|
    tm.name = team[:name]
    tm.organization_id = team[:organization_id]
    tm.active = team[:active]
    tm.owner_id = team[:owner_id]
    tm.ancestry = team[:ancestry]
    tm.team_type = team[:team_type]
    tm.save!
  end
end

def seed_team_user(team_user)
  TeamUser.new do |tu|
    tu.team_id = team_user[:team_id]
    tu.user_id = team_user[:user_id]
    tu.save!
  end
end

def seed_manage_relationship(relationship)
  ManageRelationship.new do |mr|
    mr.manageable_type = relationship[:type]
    mr.manageable_id = relationship[:entity_id]
    mr.user_id = relationship[:user_id]
    mr.save!
  end
end

def seed_objective(objective)
  Objective.new do |obj|
    obj.organization = objective[:organization]
    obj.title = objective[:title]
    obj.time_period = objective[:time_period]
    obj.current_metric = objective[:current_metric]
    obj.start_date = objective[:start_date] || obj.time_period.start_date
    obj.end_date = objective[:end_date] || obj.time_period.end_date
    obj.creator = objective[:creator] || objective[:owner]
    obj.type = 'Objective'
    obj.description = objective[:description] || nil
    obj.save!

    obj.set_owners!([objective[:owner]])
    obj.set_parents!([Objective.find(objective[:parent_id])]) if objective[:parent_id].present?
  end
end

def seed_project(project)
  Objective.new do |obj|
    obj.organization = project[:organization]
    obj.title = project[:title]
    obj.time_period = project[:time_period]
    obj.current_metric = project[:current_metric]
    obj.start_date = project[:start_date] || obj.time_period.start_date
    obj.end_date = project[:end_date] || obj.time_period.end_date
    obj.creator = project[:creator] || project[:owner]
    obj.type = 'Project'
    obj.description = project[:description] || nil
    obj.save!

    obj.set_owners!([project[:owner]])
    obj.set_entities!([project[:entity]])
    obj.set_parents!([project.find(objective[:parent_id])]) if project[:parent_id].present?
  end
end


def seed_tag(tag)
  Tag.new do |t|
    t.name = tag[:name]
    t.organization_id = tag[:organization_id]
    t.save!
  end
end

def seed_objective_entity_relationship(relationship)
  EntitySubjectRelationship.new do |esr|
    esr.subject_id = relationship[:objective_id]
    esr.subject_type = relationship[:objective_type]
    esr.entity_id = relationship[:entity_id]
    esr.entity_type = relationship[:entity_type]
    esr.save!
  end
end

def seed_checkin(checkin)
  CheckIn.new do |chk|
    chk.check_in_able = checkin[:check_in_able]
    chk.user_id = checkin[:user_id]
    chk.status = checkin[:status]
    chk.note = checkin[:note] || nil
    chk.metric_current_value = checkin[:metric_current_value]
    chk.metric_id = checkin[:metric_id]
    chk.score = checkin[:score] || nil
    chk.created_at = checkin[:created_at] || Time.now
    chk.save!
  end
end

def seed_activity (activity)
  PublicActivity::Activity.new do |act|
    act.trackable_id = activity[:trackable_id]
    act.trackable_type = activity[:trackable_type]
    act.owner_id = activity[:owner_id]
    act.owner_type = activity[:owner_type]
    act.key = activity[:key]
    act.parameters['check_in_able_id'] = activity[:parameters]['check_in_able_id']
    act.parameters['user_id'] = activity[:parameters]['user_id']
    act.parameters['status'] = activity[:parameters]['status']
    act.parameters['note'] = activity[:parameters]['note'] || nil
    act.parameters['score'] = activity[:parameters]['score'] if activity[:parameters]['score']
    act.parameters['metric_current_value'] = activity[:parameters]['metric_current_value']
    act.parameters['check_in_able_type'] = activity[:parameters]['check_in_able_type']
    act.parameters['mode'] = activity[:parameters]['mode']
    act.parameters['metric_id'] = activity[:parameters]['metric_id']
    act.parameters['auto_mode_key_result_id'] = activity[:parameters]['auto_mode_key_result_id']
    act.parameters['source'] = activity[:parameters]['source']
    act.parameters['uuid'] = activity[:parameters]['uuid']
    act.parameters['id'] = activity[:parameters]['id']
    act.save!
  end
end

def seed_integration (integration)
  OrganizationIntegration.new do |int|
    int.organization_id = integration[:organization_id]
    int.integration_id = integration[:integration_id]
    int.enabled = integration[:enabled]
    int.save!
  end
end

def seed_connection (connection)
  Connection.new do |con|
    con.name = connection[:name]
    con.type = connection[:type]
    con.active = connection[:active]
    con.creator_id = connection[:creator_id]
    con.public = true
    con.organization_integration_id = connection[:organization_integration_id]
    con.organization_id = connection[:organization_id]
    con.credentials = connection[:credentials]
    con.save!
  end
end

def seed_time_period (period)
   TimePeriod.new do |time_period|
    time_period.name = period[:name]
    time_period.organization_id = period[:organization_id]
    time_period.start_date = period[:start_date]
    time_period.end_date = period[:end_date]
    time_period.mode = 1
    time_period.save!
   end
end

def seed_data_link (dataLink)
    DataLink.new do |dl|
        dl.connection_id = dataLink[:connection_id]
        dl.objective_id = dataLink[:objective_id]
        dl.parameters = dataLink[:parameters]
        dl.last_sync = dataLink[:last_sync]
        dl.retry_count = dataLink[:retry_count]
        dl.error_message = dataLink[:error_message]
        dl.save!
    end
end

def seed_entity_note (note)
    EntityNote.new do |n|
        n.entity_id = note[:entity_id]
        n.entity_type = note[:entity_type]
        n.creator_id = note[:creator_id]
        n.organization_id = note[:organization_id]
        n.body = note[:body]
        n.body_quill_content = note[:body_quill_content]
        n.body_quill_html = note[:body_quill_html]
        n.save!
    end
end

def seed_dashboard (dashboard)
    Dashboard.new do |d|
        d.entity_id = dashboard[:entity_id]
        d.entity_type = dashboard[:entity_type]
        d.save!
    end
end

def seed_panel (panel)
    Panel.new do |p|
        p.title = panel[:title]
        p.dashboard_id = panel[:dashboard_id]
        p.index = panel[:index]
        p.save!
    end
end

def seed_panel_widget (widget)
    PanelWidget.new do |panel_widget|
        panel_widget.panel_id = widget[:panel_id]
        panel_widget.data = widget[:data]
        panel_widget.creator_id = widget[:creator_id]
        panel_widget.component = widget[:component]
        panel_widget.save!
    end
end
  test_organization = seed_organization({domain: 'org16033078953651.com', name: 'org16033078953651'})

  admin = seed_user({name: 'user16033078953752', email: 'user16033078953752@org16033078953651.com', password: 'AllyQA123', organization_id: test_organization.id})
Organization.find_by(name:'org16033078953651').managers << admin
admin.setup_guide.update!(steps: {"show_help"=>false, "show_tour"=>false, "take_tour"=>false, "watch_video"=>false, "invite_users"=>false, "add_objective"=>false, "create_account"=>true, "get_mobile_app"=>{"enabled"=>false, "completed"=>false, },"connect_messaging"=>false, "connected_to_slack"=>false, "first_user_invited"=>false, "new_role_onboarding"=>{"show_support_guider"=>false, "show_objective_modal"=>false, "show_team_admin_modal"=>false, "show_team_member_modal"=>false, "has_seen_objective_modal"=>false, "has_seen_team_admin_modal"=>false, "has_seen_team_member_modal"=>false, },"explore_integrations"=>false, "project_recommendation"=>false, "first_objective_created"=>true})
  test_organization.update!(owner: admin)
test_organization.update!({"mobile_promotion_enabled"=>false , "ui_change_explanatory_info_enabled"=>false , "project_settings" =>{"enabled"=>true , "projects_label"=>"Projects" ,  } })
  admin.update!(manager: admin)
  test_organization.managers << admin
  seed_billing_subscription({organization_id: test_organization.id, billing_name: 'user16033078953752', billing_email: 'user16033078953752@org16033078953651.com', billing_plan: [3] , status: 'trialing', trial_ends_at: Time.now + 14.days})

  objVar16033078954753 = seed_objective({organization: Organization.find_by(name:'org16033078953651'), title: 'OKR1', owner: User.find_by(email: 'user16033078953752@org16033078953651.com'), time_period: TimePeriod.find_by(organization_id:Organization.find_by(name:'org16033078953651').id, name:'Q4 2020'), start_date: '2020-10-07', end_date: '2020-10-30'})

 seed_objective_entity_relationship(objective_id: objVar16033078954753.id, entity_id: Organization.find_by(name:'org16033078953651').id, entity_type: Organization.find_by(name:'org16033078953651').class.name, objective_type: 'Objective')
  objVar16033078954914 = seed_project({organization: Organization.find_by(name:'org16033078953651'), title: 'OKR1project', owner: User.find_by(email: 'user16033078953752@org16033078953651.com'), time_period: TimePeriod.find_by(organization_id:Organization.find_by(name:'org16033078953651').id, name:'Q4 2020'), start_date: '2020-10-07', end_date: '2020-10-30'})

 seed_objective_entity_relationship(objective_id: objVar16033078954914.id, entity_id: Organization.find_by(name:'org16033078953651').id, entity_type: Organization.find_by(name:'org16033078953651').class.name, objective_type: 'Objective')
  objVar16033078954914.add_parent!(objVar16033078954753)
