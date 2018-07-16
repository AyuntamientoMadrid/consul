# coding: utf-8
# Default admin user (change password after first deploy to a server!)
if Administrator.count == 0 && !Rails.env.test?
  admin = User.create!(username: 'admin', email: 'admin@consul.dev', password: '12345678', password_confirmation: '12345678', confirmed_at: Time.current, terms_of_service: "1")
  admin.create_administrator
end

# Names for the moderation console, as a hint for moderators
# to know better how to assign users with official positions
Setting["official_level_1_name"] = "Empleados públicos"
Setting["official_level_2_name"] = "Organización Municipal"
Setting["official_level_3_name"] = "Directores generales"
Setting["official_level_4_name"] = "Concejales"
Setting["official_level_5_name"] = "Alcaldesa"

# Max percentage of allowed anonymous votes on a debate
Setting["max_ratio_anon_votes_on_debates"] = 50

# Max votes where a debate is still editable
Setting["max_votes_for_debate_edit"] = 1000

# Max votes where a proposal is still editable
Setting["max_votes_for_proposal_edit"] = 1000

# Max length for comments
Setting['comments_body_max_length'] = 1000

# Prefix for the Proposal codes
Setting["proposal_code_prefix"] = 'MAD'

# Number of votes needed for proposal success
Setting["votes_for_proposal_success"] = 53726

# Months to archive proposals
Setting["months_to_archive_proposals"] = 12

# Users with this email domain will automatically be marked as level 1 officials
# Emails under the domain's subdomains will also be included
Setting["email_domain_for_officials"] = ''

# Code to be included at the top (inside <head>) of every page (useful for tracking)
Setting['per_page_code_head'] = ''

# Code to be included at the top (inside <body>) of every page
Setting['per_page_code_body'] = ''

# Social settings
Setting["twitter_handle"] = "abriendomadrid"
Setting["twitter_hashtag"] = "#decidemadrid"
Setting["facebook_handle"] = "Abriendo-Madrid-1475577616080350"
Setting["youtube_handle"] = "channel/UCFmaChI9quIY7lwHplnacfg"
Setting["telegram_handle"] = nil
Setting["instagram_handle"] = "decidemadrid"
Setting["blog_url"] = "https://diario.madrid.es/decidemadrid/"
Setting["transparency_url"] = "http://transparencia.madrid.es/"
Setting["opendata_url"] = "http://datos.madrid.es/"

# Public-facing URL of the app.
Setting["url"] = "https://decide.madrid.es"

# Consul installation's organization name
Setting["org_name"] = "Decide Madrid"

# Consul installation place name (City, Country...)
Setting["place_name"] = "Madrid"

# Meta tags for SEO
Setting["meta_title"] = nil
Setting["meta_description"] = nil
Setting["meta_keywords"] = nil

# Feature flags
Setting['feature.debates'] = true
Setting['feature.proposals'] = true
Setting['feature.spending_proposals'] = nil
Setting['feature.polls'] = true
Setting['feature.twitter_login'] = true
Setting['feature.facebook_login'] = true
Setting['feature.google_login'] = true
Setting['feature.public_stats'] = true
Setting['feature.budgets'] = true
Setting['feature.signature_sheets'] = true
Setting['feature.legislation'] = true
Setting['feature.user.recommendations'] = true
Setting['feature.user.recommendations_on_debates'] = true
Setting['feature.user.recommendations_on_proposals'] = true
Setting['feature.community'] = true
Setting['feature.map'] = nil
Setting['feature.allow_images'] = true
Setting['feature.allow_attached_documents'] = true
Setting['feature.guides'] = nil

# Spending proposals feature flags
Setting['feature.spending_proposal_features.phase1'] = true
Setting['feature.spending_proposal_features.phase2'] = nil
Setting['feature.spending_proposal_features.phase3'] = nil
Setting['feature.spending_proposal_features.voting_allowed'] = nil
Setting['feature.spending_proposal_features.final_voting_allowed'] = true
Setting['feature.spending_proposal_features.open_results_page'] = nil
Setting['feature.spending_proposal_features.valuation_allowed'] = nil

# Banner styles
Setting['banner-style.banner-style-one']   = "Banner style 1"
Setting['banner-style.banner-style-two']   = "Banner style 2"
Setting['banner-style.banner-style-three'] = "Banner style 3"

# Banner images
Setting['banner-img.banner-img-one']   = "Banner image 1"
Setting['banner-img.banner-img-two']   = "Banner image 2"
Setting['banner-img.banner-img-three'] = "Banner image 3"

# Proposal notifications
Setting['proposal_notification_minimum_interval_in_days'] = 3
Setting['direct_message_max_per_day'] = 3

# Email settings
Setting['mailer_from_name'] = 'CONSUL'
Setting['mailer_from_address'] = 'noreply@consul.dev'

# Verification settings
Setting['verification_offices_url'] = 'http://www.madrid.es/portales/munimadrid/es/Inicio/El-Ayuntamiento/Atencion-al-ciudadano/Oficinas-de-Atencion-al-Ciudadano?vgnextfmt=default&vgnextchannel=5b99cde2e09a4310VgnVCM1000000b205a0aRCRD'
Setting['min_age_to_participate'] = 16
Setting['min_age_to_verify'] = 16

# Proposal improvement url path ('/help/proposal-improvement')
Setting['proposal_improvement_path'] = nil

# City map feature default configuration (Greenwich)
Setting['map_latitude'] = 40.4332002
Setting['map_longitude'] = -3.7009591
Setting['map_zoom'] = 10

# Related content
Setting['related_content_score_threshold'] = -0.3

Setting["feature.user.skip_verification"] = 'true'

Setting['feature.homepage.widgets.feeds.proposals'] = true
Setting['feature.homepage.widgets.feeds.debates'] = true
Setting['feature.homepage.widgets.feeds.processes'] = true


# ----------------------------------------------------------------------------

key = I18nContent.create(key: 'budgets.index.section_footer.description')
  key.update(value_es: 'Con los presupuestos participativos la ciudadanía decide a qué proyectos presentados por los vecinos y vecinas va destinada una parte del presupuesto municipal.')
  key.update(value_en: 'With the participatory budgets the citizens decide to which projects presented by the neighbors is destined a part of the municipal budget.')

  key = I18nContent.create(key: 'budgets.index.section_footer.help_text_1')
  key.update(value_es: "Los presupuestos participativos son unos procesos en los que la ciudadanía decide de forma directa en qué se gasta una parte del presupuesto municipal. Cualquier persona empadronada mayor de 16 años puede proponer un proyecto de gasto que se preselecciona en una fase de apoyos ciudadanos.")
  key.update(value_en: "Participatory budgets are processes in which citizens decide directly on what is spent part of the municipal budget. Any registered person over 16 years old can propose an investment project that is preselected in a phase of citizen supports.")

  key = I18nContent.create(key: 'budgets.index.section_footer.help_text_2')
  key.update(value_es: "Los proyectos más votados se evalúan y pasan a una votación final en la que se deciden las actuaciones que llevará a cabo el Ayuntamiento una vez se aprueben los presupuestos municipales del año próximo.")
  key.update(value_en: "The most voted projects are evaluated and passed to a final vote in which they decide the actions to be carried out by the City Council once the municipal budgets of the next year are approved.")
  key = I18nContent.create(key: 'budgets.index.section_footer.help_text_3')
  key.update(value_es: "La presentación de proyectos de presupuestos participativos se lleva a cabo desde enero y a lo largo de un periodo de mes y medio, aproximadamente. Para participar y plantear propuestas para toda la ciudad y/ los distritos hay que registrarse en %{org} y verificar la cuenta.")
  key.update(value_en: "The presentation of participatory budgeting projects takes place from January and over a period of one and a half months. To participate and propose proposals for the entire city and / or districts, you must sign up on %{org} and verify your account.")
  key = I18nContent.create(key: 'budgets.index.section_footer.help_text_4')
  key.update(value_es: "Para conseguir el mayor número de apoyos y votos posible, elige un titular descriptivo y comprensible de tu proyecto. Después tienes un espacio para desarrollar el planteamiento de tu propuesta. Aporta todos los datos y explicaciones, e incluso documentos e imágenes, para ayudar a otras personas participantes a entender mejor lo que planteas.")
  key.update(value_en: "To get as many supports and votes as possible, choose a descriptive and understandable headline for your project. Then you have a space to develop the approach of your proposal. Provide all the data and explanations, and even documents and images, to help other participants to better understand what you are proposing.")

  key = I18nContent.create(key: 'community.topic.sidebar.recommendation_one')
  key.update(value_es: 'No escribas el título del tema o frases enteras en mayúsculas. En internet eso se considera gritar. Y a nadie le gusta que le griten.')
  key.update(value_en: 'Do not write the topic title or whole sentences in capital letters. On the internet that is considered shouting. And no one likes to be yelled at.')
  key = I18nContent.create(key: 'community.topic.sidebar.recommendation_two')
  key.update(value_es: 'Cualquier tema o comentario que implique una acción ilegal será eliminada, también las que tengan la intención de sabotear los espacios del tema, todo lo demás está permitido.')
  key.update(value_en: 'Any topic or comment that implies an illegal action will be eliminated, also those that intend to sabotage the spaces of the subject, everything else is allowed.')
  key = I18nContent.create(key: 'community.topic.sidebar.recommendation_three')
  key.update(value_es: 'Disfruta de este espacio, de las voces que lo llenan, también es tuyo')
  key.update(value_en: "Enjoy this space, the voices that fill it, it's yours too.")

  key = I18nContent.create(key: 'devise.registrations.destroyed')
  key.update(value_es: "¡Adiós! Tu cuenta ha sido cancelada. Esperamos volver a verte pronto. Le informamos que de conformidad con su petición, sus datos personales registrados como usuario de la Web y que forman parte del fichero 'Fichero' cuyo responsable es 'Responsable', han sido cancelados en los términos de lo previsto en el artículo 16 de la Ley Orgánica 15/1999 de Protección de Datos de Carácter Personal y del artículo 31 de su Reglamento de desarrollo (RD 1720/2007).")
  key.update(value_en: "Goodbye! Your account has been cancelled. We hope to see you again soon. In accordance with your request, personal data registered as
      a user of the site and form part of the file 'File' under the responsibility of the
      'Responsible', they have been canceled under the terms of the provisions of Article 16 of the
      Ley Orgánica 15/1999 de Protección de Datos de Carácter Personal and Article 31 of its Reglamento de desarrollo (RD 1720/2007).")

  key = I18nContent.create(key: 'devise_views.mailer.confirmation_instructions.title')
  key.update(value_es: 'Te damos la bienvenida al Portal de Gobierno Abierto')
  key.update(value_en: 'Welcome to the Open Government Portal')

  key = I18nContent.create(key: 'debates.index.section_footer.description')
  key.update(value_es: 'Inicia un debate para compartir puntos de vista con otras personas sobre los temas que te preocupan.')
  key.update(value_en: 'Start a debate to share opinions with others about the topics you are concerned about.')
  key = I18nContent.create(key: 'debates.index.section_footer.help_text_1')
  key.update(value_es: "El espacio de debates ciudadanos está dirigido a que cualquier persona pueda exponer temas que le preocupan y sobre los que quiera compartir puntos de vista con otras personas.")
  key.update(value_en: "The space for citizen debates is aimed at anyone who can expose issues of their concern and those who want to share opinions with other people.")
  key = I18nContent.create(key: 'debates.index.section_footer.help_text_2')
  key.update(value_es: 'Para abrir un debate es necesario registrarse en %{org}. Los usuarios ya registrados también pueden comentar los debates abiertos y valorarlos con los botones de "Estoy de acuerdo" o "No estoy de acuerdo" que se encuentran en cada uno de ellos.')
  key.update(value_en: 'To open a debate you need to sign up on %{org}. Users can also comment on open debates and rate them with the "I agree" or "I disagree" buttons found in each of them.')
  key = I18nContent.create(key: 'debates.index.section_footer.help_text_3')
  key.update(value_es: "Ten en cuenta que un debate no activa ningún mecanismo de actuación concreto. Si quieres hacer una %{proposal} para la ciudad o plantear un proyecto de %{budget} cuando se abra la convocatoria, ve a la sección correspondiente.")
  key.update(value_en: "Keep in mind that a debate does not start any specific action. If you want to make a %{proposal} for the city or raise a investment project of %{budget} when the phase is open, go to the corresponding section.")

  key = I18nContent.create(key: 'debates.new.recommendation_one')
  key.update(value_es: 'No escribas el título del debate o frases enteras en mayúsculas. En internet eso se considera gritar. Y a nadie le gusta que le griten.')
  key.update(value_en: 'Do not use capital letters for the debate title or for whole sentences. On the internet, this is considered shouting. And nobody likes being shouted at.')
  key = I18nContent.create(key: 'debates.new.recommendation_two')
  key.update(value_es: 'Cualquier debate o comentario que implique una acción ilegal será eliminado, también los que tengan la intención de sabotear los espacios de debate, todo lo demás está permitido.')
  key.update(value_en: 'Any debate or comment suggesting illegal action will be deleted, as well as those intending to sabotage the debate spaces. Anything else is allowed.')
  key = I18nContent.create(key: 'debates.new.recommendation_three')
  key.update(value_es: 'Las críticas despiadadas son muy bienvenidas. Este es un espacio de pensamiento. Pero te recomendamos conservar la elegancia y la inteligencia. El mundo es mejor con ellas presentes.')
  key.update(value_en: 'Ruthless criticism is very welcome. This is a space for reflection. But we recommend that you stick to elegance and intelligence. The world is a better place with these virtues in it.')
  key = I18nContent.create(key: 'debates.new.recommendation_four')
  key.update(value_es: 'Disfruta de este espacio, de las voces que lo llenan, también es tuyo.')
  key.update(value_en: 'Enjoy this space and the voices that fill it. It belongs to you too.')

  key = I18nContent.create(key: 'layouts.footer.accessibility')
  key.update(value_es: 'Accesibilidad')
  key.update(value_en: 'Accessibility')
  key = I18nContent.create(key: 'layouts.footer.conditions')
  key.update(value_es: 'Condiciones de uso')
  key.update(value_en: 'Terms and conditions of use')
  key = I18nContent.create(key: 'layouts.footer.privacy')
  key.update(value_es: 'Política de privacidad')
  key.update(value_en: 'Privacy Policy')

  key = I18nContent.create(key: 'proposals.index.section_footer.description')
  key.update(value_es: 'Regístrate para poder votar propuestas ciudadanas y las cuestiones que pregunta a sus vecinos el Ayuntamiento. Toma decisiones municipales de forma directa.')
  key.update(value_en: 'Make a citizen proposal. If it gets enough supports it will go to voting phase, so you can get all the citizens to decide how they want their city to be.')
  key = I18nContent.create(key: 'proposals.index.section_footer.help_text_1')
  key.update(value_es: "Las propuestas ciudadanas son una oportunidad para que los vecinos y colectivos decidan directamente cómo quieren que sea su ciudad. Cualquier persona puede hacer una propuesta sobre un tema que le interese o preocupe para que el ayuntamiento la lleve a cabo, después de conseguir los apoyos suficientes y de someterse a votación ciudadana.")
  key.update(value_en: "The citizen proposals are an opportunity for neighbours and collectives to decide directly how they want to shape their city. Any person can make a proposal about a topic or concern of their interest, for the City Council to make it, after it gets enough supports to be put to a citizens vote.")
  key = I18nContent.create(key: 'proposals.index.section_footer.help_text_2')
  key.update(value_es: "Para crear una propuesta hay que registrarse en %{org}. Las propuestas que consigan el apoyo del 1% de la gente en la web, pasan a votación. Para apoyar propuestas es necesario tener una cuenta verificada.")
  key.update(value_en: "To create a proposal, you must sign up on %{org}. The proposals that get the support of 1% of the users in the web, goes to voting phase. To support proposals it is necessary to have a verified account.")
  key = I18nContent.create(key: 'proposals.index.section_footer.help_text_3')
  key.update(value_es: "Se convoca una votación ciudadana cuando las propuestas consiguen los apoyos necesarios. Una vez celebrada, si hay más gente a favor que en contra, el Consistorio asume la propuesta y la lleva a cabo.")
  key.update(value_en: "A citizen vote is celebrated when the proposals get the necessary supports. Once celebrated, if there are more people in favor than against, the City Council assumes the proposal and carries it out.")

  key = I18nContent.create(key: 'proposals.new.form.submit_button')
  key.update(value_es: 'Crear propuesta')
  key.update(value_en: 'Create proposal')
  key = I18nContent.create(key: 'proposals.new.form.more_info')
  key.update(value_es: '¿Cómo funcionan las propuestas ciudadanas?')
  key.update(value_en: 'How do citizen proposals work?')
  key = I18nContent.create(key: 'proposals.new.form.recommendation_one')
  key.update(value_es: 'No escribas el título de la propuesta o frases enteras en mayúsculas. En internet eso se considera gritar. Y a nadie le gusta que le griten.')
  key.update(value_en: 'Do not use capital letters for the proposal title or for whole sentences. On the internet, this is considered shouting. And nobody likes being shouted at.')
  key = I18nContent.create(key: 'proposals.new.form.recommendation_two')
  key.update(value_es: 'Cualquier propuesta o comentario que implique una acción ilegal será eliminada, también las que tengan la intención de sabotear los espacios de propuesta, todo lo demás está permitido.')
  key.update(value_en: "To create a proposal, you must sign up on %{org}. The proposals that get the support of 1% of the users in the web, goes to voting phase. To support proposals it is necessary to have a verified account.")
  key = I18nContent.create(key: 'proposals.new.form.recommendation_three')
  key.update(value_es: 'Disfruta de este espacio, de las voces que lo llenan, también es tuyo.')
  key.update(value_en: 'Enjoy this space and the voices that fill it. It belongs to you too.')

  key = I18nContent.create(key: 'proposals.proposal.reason_for_supports_necessary')
  key.update(value_es: '1% del Censo')
  key.update(value_en: '1% of Census')

  key = I18nContent.create(key: 'polls.index.section_footer.description')
  key.update(value_es: 'Regístrate para poder votar propuestas ciudadanas y las cuestiones que pregunta a sus vecinos el Ayuntamiento. Toma decisiones municipales de forma directa.')
  key.update(value_en: 'Sign up to vote on citizen proposals and questions the City Council ask to the neighbors. Make municipal decisions directly.')
  key = I18nContent.create(key: 'polls.index.section_footer.help_text_1')
  key.update(value_es: "Las votaciones se convocan cuando una propuesta ciudadana alcanza el 1% de apoyos del censo con derecho a voto. En las votaciones también se pueden incluir cuestiones que el Ayuntamiento somete a decisión directa de la ciudadanía.")
  key.update(value_en: "Voting takes place when a citizen proposal supports reaches 1% of the census with voting rights. Voting can also include questions that the City Council ask to the citizens decision.")
  key = I18nContent.create(key: 'polls.index.section_footer.help_text_2')
  key.update(value_es: "Para participar en la próxima votación tienes que registrarte en %{org} y verificar tu cuenta. Pueden votar todas las personas empadronadas en la ciudad mayores de 16 años. Los resultados de todas las votaciones serán vinculantes para el gobierno.")
  key.update(value_en: "To participate in the next vote you have to sign up on %{org} and verify your account. All registered voters in the city over 16 years old can vote. The results of all votes are binding on the government.")

  key = I18nContent.create(key: 'legislation.processes.index.section_footer.description')
  key.update(value_es: 'Participa en los debates y procesos previos a la aprobación de una norma o de una actuación municipal. Tu opinión será tenida en cuenta por el Ayuntamiento.')
  key.update(value_en: 'Participate in the debates and processes prior to the approval of a ordinance or a municipal action. Your opinion will be considered by the City Council.')
  key = I18nContent.create(key: 'legislation.processes.index.section_footer.help_text_1')
  key.update(value_es: "En los procesos participativos, el Ayuntamiento ofrece a la ciudadanía la oportunidad de participar en la elaboración y modificación de normativa que afecta a la ciudad y de dar su opinión sobre ciertas actuaciones que tiene previsto llevar a cabo.")
  key.update(value_en: "In participatory processes, the City Council offers to its citizens the opportunity to participate in the drafting and modification of regulations, affecting the city and to be able to give their opinion on certain actions that it plans to carry out.")
  key = I18nContent.create(key: 'legislation.processes.index.section_footer.help_text_2')
  key.update(value_es: "Las personas registradas en %{org} pueden participar con aportaciones en la consulta pública de nuevas ordenanzas, reglamentos y directrices, entre otros. Sus comentarios son analizados por el área correspondiente y tenidos en cuenta de cara a la redacción final de las normas.")
  key.update(value_en: "People registered in %{org} can participate with contributions in the public consultation of new ordinances, regulations and guidelines, among others. Your comments are analyzed by the corresponding area and considered for the final drafting of the ordinances.")
  key = I18nContent.create(key: 'legislation.processes.index.section_footer.help_text_3')
  key.update(value_es: "El Ayuntamiento también abre procesos para recibir aportaciones y opiniones sobre actuaciones municipales.")
  key.update(value_en: "The City Council also opens processes to receive contributions and opinions on municipal actions.")

  key = I18nContent.create(key: 'management.print.proposals_info')
  key.update(value_es: 'Haz tu propuesta en http://url.consul')
  key.update(value_en: 'Create yor proposal on http://decide.madrid.es')
  key = I18nContent.create(key: 'management.print.proposals_note')
  key.update(value_es: 'Las propuestas más apoyadas serán llevadas a votación. Y si las acepta una mayoría, el Ayuntamiento las llevará a cabo.')
  key.update(value_en: 'The proposals more supported will be voted. If are accepted by a majority, the city Council shall be carried out.')
  key = I18nContent.create(key: 'management.print.proposals_title')
  key.update(value_es: 'Propuestas:')
  key.update(value_en: 'Proposals:')
  key = I18nContent.create(key: 'management.print.budget_investments_info')
  key.update(value_es: 'Participa en http://url.consul')
  key.update(value_en: 'Participate at http://decide.madrid.es')
  key = I18nContent.create(key: 'management.print.budget_investments_note')
  key.update(value_es: 'Los presupuestos participativos se invertirán en los proyectos de gasto más apoyados.')
  key.update(value_en: 'Participatory budget will be assigned to the most voted budget investment.')

  key = I18nContent.create(key: 'guides.title')
  key.update(value_es: "¿Tienes una idea para %{org}?")
  key.update(value_en: "Do you have an idea for %{org}?")
  key = I18nContent.create(key: 'guides.subtitle')
  key.update(value_es: "Elige qué quieres crear")
  key.update(value_en: "Choose what you want to create")
  key = I18nContent.create(key: 'guides.budget_investment.title')
  key.update(value_es: "Un proyecto de gasto")
  key.update(value_en: "An investment project")
  key = I18nContent.create(key: 'guides.budget_investment.feature_1_html')
  key.update(value_es: "Son ideas de cómo gastar parte del <strong>presupuesto municipal</strong>")
  key.update(value_en: "Ideas of how to spend part of the <strong>municipal budget</strong>")
  key = I18nContent.create(key: 'guides.budget_investment.feature_2_html')
  key.update(value_es: "Los proyectos de gasto se plantean <strong>entre enero y marzo</strong>")
  key.update(value_en: "Investment projects are accepted <strong>between January and March</strong>")
  key = I18nContent.create(key: 'guides.budget_investment.feature_3_html')
  key.update(value_es: "Si recibe apoyos, es viable y competencia municipal, pasa a votación")
  key.update(value_en: "If it receives supports, it's viable and municipal competence, it goes to voting phase")
  key = I18nContent.create(key: 'guides.budget_investment.feature_4_html')
  key.update(value_es: "Si la ciudadanía aprueba los proyectos, se hacen realidad")
  key.update(value_en: "If the citizens approve the projects, they become a reality")
  key = I18nContent.create(key: 'guides.budget_investment.new_button')
  key.update(value_es: 'Quiero crear un proyecto de gasto')
  key.update(value_en: 'I want to create a budget investment')
  key = I18nContent.create(key: 'guides.proposal.title')
  key.update(value_es: "Una propuesta ciudadana")
  key.update(value_en: "A citizen proposal")
  key = I18nContent.create(key: 'guides.proposal.feature_1_html')
  key.update(value_es: "Son ideas sobre cualquier acción que pueda realizar el Ayuntamiento")
  key.update(value_en: "Ideas about any action the City Council can take")
  key = I18nContent.create(key: 'guides.proposal.feature_2_html')
  key.update(value_es: "Necesitan <strong>%{votes} apoyos</strong> en %{org} para pasar a votación")
  key.update(value_en: "Need <strong>%{votes} supports</strong> in %{org} for go to voting")
  key = I18nContent.create(key: 'guides.proposal.feature_3_html')
  key.update(value_es: "Se activan en cualquier momento; tienes <strong>un año</strong> para reunir los apoyos")
  key.update(value_en: "Activate at any time, you have <strong>a year</strong> to get the supports")
  key = I18nContent.create(key: 'guides.proposal.feature_4_html')
  key.update(value_es: "De aprobarse en votación, el Ayuntamiento asume la propuesta")
  key.update(value_en: "If approved in a vote, the City Council accepts the proposal")
  key = I18nContent.create(key: 'guides.proposal.new_button')
  key.update(value_es: "Quiero crear una propuesta")
  key.update(value_en: 'I want to create a proposal')

  key = I18nContent.create(key: 'mailers.no_reply')
  key.update(value_es: "Este mensaje se ha enviado desde una dirección de correo electrónico que no admite respuestas.")
  key.update(value_en: "This message was sent from an email address that does not accept replies.")

  key = I18nContent.create(key: 'mailers.comment.hi')
  key.update(value_es: 'Hola')
  key.update(value_en: 'Hi')
  key = I18nContent.create(key: 'mailers.comment.new_comment_by_html')
  key.update(value_es: 'Hay un nuevo comentario de <b>%{commenter}</b> en')
  key.update(value_en: 'There is a new comment from <b>%{commenter}</b>')
  key = I18nContent.create(key: 'mailers.comment.subject')
  key.update(value_es: 'Alguien ha comentado en tu %{commentable}')
  key.update(value_en: 'Someone has commented on your %{commentable}')
  key = I18nContent.create(key: 'mailers.comment.title')
  key.update(value_es: 'Nuevo comentario')
  key.update(value_en: 'New comment')

  key = I18nContent.create(key: 'mailers.config.manage_email_subscriptions')
  key.update(value_es: 'Puedes dejar de recibir estos emails cambiando tu configuración en')
  key.update(value_en: 'To stop receiving these emails change your settings in')

  key = I18nContent.create(key: 'mailers.email_verification.click_here_to_verify')
  key.update(value_es: 'en este enlace')
  key.update(value_en: 'this link')
  key = I18nContent.create(key: 'mailers.email_verification.instructions_2_html')
  key.update(value_es: 'Este email es para verificar tu cuenta con <b>%{document_type} %{document_number}</b>. Si esos no son tus datos, por favor no pulses el enlace anterior e ignora este email.')
  key.update(value_en: "This email will verify your account with <b>%{document_type} %{document_number}</b>. If these don't belong to you, please don't click on the previous link and ignore this email.")
  key = I18nContent.create(key: 'mailers.email_verification.instructions_html')
  key.update(value_es: 'Para terminar de verificar tu cuenta de usuario en el Portal de Gobierno Abierto del Ayuntamiento de Madrid, necesitamos que pulses %{verification_link}.')
  key.update(value_en: 'To complete the verification of your user account in the Open Government Portal of the Madrid City Council, you must click %{verification_link}.')
  key = I18nContent.create(key: 'mailers.email_verification.subject')
  key.update(value_es: 'Verifica tu email')
  key.update(value_en: 'Confirm your email')
  key = I18nContent.create(key: 'mailers.email_verification.thanks')
  key.update(value_es: 'Muchas gracias.')
  key.update(value_en: 'Thank you very much.')
  key = I18nContent.create(key: 'mailers.email_verification.title')
  key.update(value_es: 'Verifica tu cuenta con el siguiente enlace')
  key.update(value_en: 'Confirm your account using the following link')

  key = I18nContent.create(key: 'mailers.reply.hi')
  key.update(value_es: 'Hola')
  key.update(value_en: 'Hi')
  key = I18nContent.create(key: 'mailers.reply.new_reply_by_html')
  key.update(value_es: 'Hay una nueva respuesta de <b>%{commenter}</b> a tu comentario en')
  key.update(value_en: 'There is a new response from <b>%{commenter}</b> to your comment on')
  key = I18nContent.create(key: 'mailers.reply.subject')
  key.update(value_es: 'Alguien ha respondido a tu comentario')
  key.update(value_en: 'Someone has responded to your comment')
  key = I18nContent.create(key: 'mailers.reply.title')
  key.update(value_es: 'Nueva respuesta a tu comentario')
  key.update(value_en: 'New response to your comment')

  key = I18nContent.create(key: 'mailers.unfeasible_spending_proposal.hi')
  key.update(value_es: "Estimado usuario,")
  key.update(value_en: "Dear user,")
  key = I18nContent.create(key: 'mailers.unfeasible_spending_proposal.reconsider_html')
  key.update(value_es: "Si consideras que la propuesta rechazada cumple los requisitos para mantenerla como propuesta de inversión, podrás comunicarlo, en el plazo de 48 horas, al correo example@consul.es, indicando necesariamente para su tramitación el código %{code} como asunto del correo, correspondiente a tu propuesta.")
  key.update(value_en: "Should the proposed creation phase be finished, you can send us improvements to your proposal within 48 hours, responding to the email address preparticipativos@madrid.es. Including the code %{code} in the subject of the email.")
  key = I18nContent.create(key: 'mailers.unfeasible_spending_proposal.sincerely')
  key.update(value_es: "Atentamente")
  key.update(value_en: "Sincerely")
  key = I18nContent.create(key: 'mailers.unfeasible_spending_proposal.signatory')
  key.update(value_es: "DIRECCIÓN GENERAL DE PARTICIPACIÓN CIUDADANA")
  key.update(value_en: "DEPARTMENT OF PUBLIC PARTICIPATION")
  key = I18nContent.create(key: 'mailers.unfeasible_spending_proposal.sorry')
  key.update(value_es: "Sentimos las molestias ocasionadas y volvemos a darte las gracias por tu inestimable participación.")
  key.update(value_en: "Sorry for the inconvenience and we again thank you for your invaluable participation.")
  key = I18nContent.create(key: 'mailers.unfeasible_spending_proposal.subject')
  key.update(value_es: "Tu propuesta de inversión '%{code}' ha sido marcada como inviable")
  key.update(value_en: "Your investment project '%{code}' has been marked as unfeasible")
  key = I18nContent.create(key: 'mailers.unfeasible_spending_proposal.unfeasible_html')
  key.update(value_es: "Desde el Ayuntamiento queremos agradecer tu participación en los <strong>Presupuestos Participativos</strong>. Lamentamos informarte de que tu propuesta <strong>'%{title}'</strong> quedará excluida de este proceso participativo por el siguiente motivo:")
  key.update(value_en: "From the City Council we want to thank you for your participation in the <strong>participatory budgets</strong>. We regret to inform you that your proposal <strong>'%{title}'</strong> will be excluded from this participatory process for the following reason:")

  key = I18nContent.create(key: 'mailers.budget_investment_unfeasible.hi')
  key.update(value_es: "Estimado usuario,")
  key.update(value_en: "Dear user,")
  key = I18nContent.create(key: 'mailers.budget_investment_unfeasible.reconsider_html')
  key.update(value_es: "Si consideras que el proyecto rechazado cumple los requisitos para mantenerlo como proyecto de gasto, podrás comunicarlo, en el plazo de 48 horas, al correo example@consul.es, indicando necesariamente para su tramitación el código %{code} como asunto del correo, correspondiente a tu proyecto.")
  key.update(value_en: "If you believe that the rejected investment meets the requirements to be an investment project, you can communicate this, within 48 hours, responding to the email address preparticipativos@madrid.es. Including the code %{code} in the subject of the email.")
  key = I18nContent.create(key: 'mailers.budget_investment_unfeasible.sincerely')
  key.update(value_es: "Atentamente")
  key.update(value_en: "Sincerely")
  key = I18nContent.create(key: 'mailers.budget_investment_unfeasible.signatory')
  key.update(value_es: "DIRECCIÓN GENERAL DE PARTICIPACIÓN CIUDADANA")
  key.update(value_en: "Área de Participación Ciudadana, Transparencia y Gobierno Abierto del Ayuntamiento de Madrid")
  key = I18nContent.create(key: 'mailers.budget_investment_unfeasible.sorry')
  key.update(value_es: "Sentimos las molestias ocasionadas y volvemos a darte las gracias por tu inestimable participación.")
  key.update(value_en: "Sorry for the inconvenience and we again thank you for your invaluable participation.")
  key = I18nContent.create(key: 'mailers.budget_investment_unfeasible.subject')
  key.update(value_es: "Tu proyecto de gasto '%{code}' ha sido marcado como inviable")
  key.update(value_en: "Your investment project '%{code}' has been marked as unfeasible")
  key = I18nContent.create(key: 'mailers.budget_investment_unfeasible.unfeasible_html')
  key.update(value_es: "Desde el Ayuntamiento queremos agradecer tu participación en los <strong>Presupuestos Participativos</strong>. Lamentamos informarte de que tu propuesta <strong>'%{title}'</strong> quedará excluida de este proceso participativo por el siguiente motivo:")
  key.update(value_en: "From the City Council we want to thank you for your participation in the <strong>participatory budgets</strong>. We regret to inform you that your investment <strong>'%{title}'</strong> will be excluded from this participatory process for the following reason:")

  key = I18nContent.create(key: 'mailers.proposal_notification_digest.info')
  key.update(value_es: "A continuación te mostramos las nuevas notificaciones que han publicado los autores de las propuestas que estás apoyando en %{org_name}.")
  key.update(value_en: "Here are the new notifications that have been published by authors of the proposals that you have supported in %{org_name}.")
  key = I18nContent.create(key: 'mailers.proposal_notification_digest.title')
  key.update(value_es: "Notificaciones de propuestas en %{org_name}")
  key.update(value_en: "Proposal notifications in %{org_name}")
  key = I18nContent.create(key: 'mailers.proposal_notification_digest.share')
  key.update(value_es: 'Compartir propuesta')
  key.update(value_en: 'Share proposal')
  key = I18nContent.create(key: 'mailers.proposal_notification_digest.comment')
  key.update(value_es: 'Comentar propuesta')
  key.update(value_en: 'Comment proposal')
  key = I18nContent.create(key: 'mailers.proposal_notification_digest.unsubscribe')
  key.update(value_es: "Si no quieres recibir notificaciones de propuestas, puedes entrar en %{account} y desmarcar la opción 'Recibir resumen de notificaciones sobre propuestas'.")
  key.update(value_en: "If you don't want receive proposal's notification, visit %{account} and unckeck 'Receive a summary of proposal notifications'.")
  key = I18nContent.create(key: 'mailers.proposal_notification_digest.unsubscribe_account')
  key.update(value_es: 'Mi cuenta')
  key.update(value_en: 'My account')

  key = I18nContent.create(key: 'mailers.direct_message_for_receiver.subject')
  key.update(value_es: "Has recibido un nuevo mensaje privado")
  key.update(value_en: "You have received a new private message")
  key = I18nContent.create(key: 'mailers.direct_message_for_receiver.reply')
  key.update(value_es: 'Responder a %{sender}')
  key.update(value_en: 'Reply to %{sender}')
  key = I18nContent.create(key: 'mailers.direct_message_for_receiver.unsubscribe')
  key.update(value_es: "Si no quieres recibir mensajes privados, puedes entrar en %{account} y desmarcar la opción 'Recibir emails con mensajes privados'.")
  key.update(value_en: "If you don't want receive direct messages, visit %{account} and unckeck 'Receive emails about direct messages'.")
  key = I18nContent.create(key: 'mailers.direct_message_for_receiver.unsubscribe_account')
  key.update(value_es: 'Mi cuenta')
  key.update(value_en: 'My account')

  key = I18nContent.create(key: 'mailers.direct_message_for_sender.subject')
  key.update(value_es: "Has enviado un nuevo mensaje privado")
  key.update(value_en: "You have send a new private message")
  key = I18nContent.create(key: 'mailers.direct_message_for_sender.title_html')
  key.update(value_es: "Has enviado un nuevo mensaje privado a <strong>%{receiver}</strong> con el siguiente contenido:")
  key.update(value_en: "You have send a new private message to <strong>%{receiver}</strong> with the content:")

  key = I18nContent.create(key: 'mailers.user_invite.ignore')
  key.update(value_es: "Si no has solicitado esta invitación no te preocupes, puedes ignorar este correo.")
  key.update(value_en: "If you have not requested this invitation don't worry, you can ignore this email.")
  key = I18nContent.create(key: 'mailers.user_invite.text')
  key.update(value_es: "¡Gracias por solicitar unirte a %{org}! En unos segundos podrás empezar a decidir la ciudad que quieres, sólo tienes que rellenar el siguiente formulario:")
  key.update(value_en: "Thank you for applying to join %{org}! In seconds you can start to decide the city you want, just fill the form below:")
  key = I18nContent.create(key: 'mailers.user_invite.thanks')
  key.update(value_es: "Muchas gracias.")
  key.update(value_en: "Thank you very much.")
  key = I18nContent.create(key: 'mailers.user_invite.title')
  key.update(value_es: "Bienvenido a %{org}")
  key.update(value_en: "Welcome to %{org}")
  key = I18nContent.create(key: 'mailers.user_invite.button')
  key.update(value_es: 'Completar registro')
  key.update(value_en: 'Complete registration')
  key = I18nContent.create(key: 'mailers.user_invite.subject')
  key.update(value_es: "Invitación a %{org_name}")
  key.update(value_en: "Invitation to %{org_name}")

  key = I18nContent.create(key: 'mailers.budget_investment_created.subject')
  key.update(value_es: "¡Gracias por crear un proyecto!")
  key.update(value_en: "Thank you for creating an investment!")
  key = I18nContent.create(key: 'mailers.budget_investment_created.title')
  key.update(value_es: "¡Gracias por crear un proyecto!")
  key.update(value_en: "Thank you for creating an investment!")
  key = I18nContent.create(key: 'mailers.budget_investment_created.intro_html')
  key.update(value_es: "Hola <strong>%{author}</strong>,")
  key.update(value_en: "Hi <strong>%{author}</strong>,")
  key = I18nContent.create(key: 'mailers.budget_investment_created.text_html')
  key.update(value_es: "Muchas gracias por crear tu proyecto <strong>%{investment}</strong> para los Presupuestos Participativos <strong>%{budget}</strong>.")
  key.update(value_en: "Thank you for creating your investment <strong>%{investment}</strong> for Participatory Budgets <strong>%{budget}</strong>.")
  key = I18nContent.create(key: 'mailers.budget_investment_created.follow_html')
  key.update(value_es: "Te informaremos de cómo avanza el proceso, que también puedes seguir en la página de <strong>%{link}</strong>.")
  key.update(value_en: "We will inform you about how the process progresses, which you can also follow on <strong>%{link}</strong>.")
  key = I18nContent.create(key: 'mailers.budget_investment_created.follow_link')
  key.update(value_es: "Presupuestos participativos")
  key.update(value_en: "Participatory Budgets")
  key = I18nContent.create(key: 'mailers.budget_investment_created.sincerely')
  key.update(value_es: "Atentamente,")
  key.update(value_en: "Sincerely,")
  key = I18nContent.create(key: 'mailers.budget_investment_created.signatory')
  key.update(value_es: "Área de Participación Ciudadana, Transparencia y Gobierno Abierto del Ayuntamiento de Madrid")
  key.update(value_en: "DEPARTMENT OF PUBLIC PARTICIPATION")
  key = I18nContent.create(key: 'mailers.budget_investment_created.share')
  key.update(value_es: "Comparte tu proyecto")
  key.update(value_en: "Share your project")

  key = I18nContent.create(key: 'mailers.budget_investment_selected.subject')
  key.update(value_es: "Tu proyecto de gasto '%{code}' ha sido seleccionado")
  key.update(value_en: "Your investment project '%{code}' has been selected")
  key = I18nContent.create(key: 'mailers.budget_investment_selected.hi')
  key.update(value_es: "Estimado/a usuario/a")
  key.update(value_en: "Dear user,")
  key = I18nContent.create(key: 'mailers.budget_investment_selected.selected_html')
  key.update(value_es: "Desde el Ayuntamiento de Madrid agradecemos que hayas participado con tu idea en los <strong>Presupuestos Participativos</strong>. Te informamos de que tu proyecto <strong>'%{title}'</strong> ha sido seleccionado y pasa a la fase de votación final que tiene lugar desde el <strong>15 de mayo hasta el 30 de junio de 2017</strong>.")
  key.update(value_en: "From the City Council we want to thank you for your participation in the <strong>participatory budgets</strong>. We would like to inform you that your investment project <strong>'%{title}'</strong> has been selected for the final voting phase that will happen from <strong>May 15th to June 30th</strong>.")
  key = I18nContent.create(key: 'mailers.budget_investment_selected.share')
  key.update(value_es: "Empieza ya a conseguir votos, comparte tu proyecto de gasto en redes sociales. La difusión es fundamental para conseguir que se haga realidad.")
  key.update(value_en: "Start to get votes, share your investment project on social networks. Share is essential to make it a reality.")
  key = I18nContent.create(key: 'mailers.budget_investment_selected.share_button')
  key.update(value_es: "Comparte tu proyecto")
  key.update(value_en: "Share your investment project")
  key = I18nContent.create(key: 'mailers.budget_investment_selected.thanks')
  key.update(value_es: "Gracias de nuevo por tu participación.")
  key.update(value_en: "Thank you again for participating.")
  key = I18nContent.create(key: 'mailers.budget_investment_selected.sincerely')
  key.update(value_es: "Atentamente")
  key.update(value_en: "Sincererly")
  key = I18nContent.create(key: 'mailers.budget_investment_selected.signatory')
  key.update(value_es: "DIRECCIÓN GENERAL DE PARTICIPACIÓN CIUDADANA")
  key.update(value_en: "DEPARTMENT OF PUBLIC PARTICIPATION")

  key = I18nContent.create(key: 'mailers.budget_investment_unselected.subject')
  key.update(value_es: "Tu proyecto de gasto '%{code}' no ha sido seleccionado")
  key.update(value_en: "Your investment project '%{code}' has not been selected")
  key = I18nContent.create(key: 'mailers.budget_investment_unselected.hi')
  key.update(value_es: "Estimado/a usuario/a")
  key.update(value_en: "Dear user,")
  key = I18nContent.create(key: 'mailers.budget_investment_unselected.unselected_html')
  key.update(value_es: "Desde el Ayuntamiento de Madrid agradecemos que hayas participado con tu idea en los <strong>Presupuestos Participativos</strong>. Lamentamos informarte de que tu proyecto <strong>'%{title}'</strong> no ha sido seleccionado para la fase de votación final.")
  key.update(value_en: "From the City Council we want to thank you for your participation in the <strong>participatory budgets</strong>. We regret to inform you that your investment project <strong>'%{title}'</strong> has not been selected for the final voting phase.")
  key = I18nContent.create(key: 'mailers.budget_investment_unselected.participate_html')
  key.update(value_es: "Puedes continuar participando en la votación final votando proyectos para toda la ciudad y el distrito que elijas desde el <strong>15 de mayo hasta el 30 de junio de 2017.</strong>")
  key.update(value_en: "You can continue participating in the final voting phase voting for investments projects from <strong>May 15th to June 30th</strong>.")
  key = I18nContent.create(key: 'mailers.budget_investment_unselected.participate_url')
  key.update(value_es: "participes en la votación final")
  key.update(value_en: "participate in the final voting")
  key = I18nContent.create(key: 'mailers.budget_investment_unselected.thanks')
  key.update(value_es: "Gracias de nuevo por tu participación.")
  key.update(value_en: "Thank you again for participating.")
  key = I18nContent.create(key: 'mailers.budget_investment_unselected.sincerely')
  key.update(value_es: "Atentamente")
  key.update(value_en: "Sincererly")
  key = I18nContent.create(key: 'mailers.budget_investment_unselected.signatory')
  key.update(value_es: "DIRECCIÓN GENERAL DE PARTICIPACIÓN CIUDADANA")
  key.update(value_en: "DEPARTMENT OF PUBLIC PARTICIPATION")
