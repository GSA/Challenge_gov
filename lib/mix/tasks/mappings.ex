defmodule Mix.Tasks.Mappings do
  @moduledoc """
  Mappings for challenge importer
  """

  def challenge_id_agency_map do
    %{
      "222" => %{"parent" => "The Executive Office of the President"},
      "399" => %{"parent" => "Legislative Branch", "component" => "U.S. House of Representatives"},
      "190" => %{"parent" => "Corporation for National and Community Service"},
      "393" => %{"parent" => "Department of State", "component" => "Office of Foreign Assistance"},
      "351" => %{"parent" => "Corporation for National and Community Service"},
      "164" => %{"parent" => "Corporation for National and Community Service"},
      "782" => %{"parent" => "Department of State"},
      "223" => %{"parent" => "The Executive Office of the President"},
      "383" => %{"parent" => "National Endowment for the Arts"},
      "139" => %{"parent" => "Department of State"},
      "183" => %{"parent" => "U.S. Agency for International Development"},
      # "183" => %{"parent" => "The Executive Office of the President", "component" => "U.S. Agency for International Development"},
      "292" => %{"parent" => "Department of State"},
      "940" => %{"parent" => "The Executive Office of the President"},
      "144" => %{"parent" => "Federal Communications Commission"},
      "805" => %{"parent" => "U.S. Agency for International Development"},
      "208" => %{"parent" => "National Archives and Records Administration"},
      "325" => %{"parent" => "Corporation for National and Community Service"},
      "23" => %{"parent" => "Department of State"},
      "571" => %{"parent" => "Department of State"},
      "132" => %{"parent" => "National Archives and Records Administration"},
      "171" => %{"parent" => "Federal Communications Commission"},
      "929" => %{"parent" => "Department of State"},
      "102" => %{"parent" => "Department of State"},
      "249" => %{"parent" => "Federal Election Commission"},
      "368" => %{"parent" => "Department of State"},
      "256" => %{"parent" => "Corporation for National and Community Service"},
      "353" => %{"parent" => "Corporation for National and Community Service"}
    }
  end

  def challenge_id_federal_partner_map do
    %{
      "1076" => [
        "Program Manager Air (PMA 263)",
        "Navy and Marine Corps Small Tactical Unmanned Aircraft Systems (STUAS)"
      ],
      "1100" => ["National Heart, Lung, and Blood Institute"],
      "1105" => [
        "NIH Office of the Director",
        "National Institute of Allergy and Infectious Disease",
        "National Heart, Lung and Blood Institute",
        "National Institute of Diabetes and Digestive and Kidney Diseases",
        "Fogarty International Center"
      ],
      "1154" => [
        "U.S. Department of Defense",
        "Strategic Environmental Research and Development Program",
        "Environmental Security Technology Certification Program"
      ],
      "1163" => ["Naval STEM Coordination Office, managed by the Office of Naval Research"],
      "1165" => [
        "Members of the National Science and Technology Council Lab to Market Subcommittee: White House Office of Science and Technology Policy (OSTP)",
        "US Department of Agriculture (USDA)",
        "Department of Commerce (NIST, NOAA)",
        "Department of Defense (DoD)",
        "Department of Education (ED)",
        "Department of Energy (DOE)",
        "Department of Health and Human Services (HHS)",
        "Department of Homeland Security (DHS)",
        "Department of Interior (DOI)",
        "Department of State (State)",
        "Department of Transportation (DOT)",
        "Department of Veterans Affairs (VA)",
        "Environmental Protection Agency (EPA)",
        "National Aeronautics and Aerospace Agency (NASA)",
        "National Science Foundation (NSF)"
      ],
      "1179" => [
        "Office of the Navy",
        "Chief of Information (CHINFO)",
        "Commander, U.S. Fleet Forces (USFF)",
        "Naval Accelerator (NavalX)"
      ],
      "1207" => [
        "CDC National Center for Environmental Health",
        "CDC National Institute of Occupational Safety and Health",
        "Department of State - Office of Occupational Health and Wellness",
        "National Institute of Standards and Technology"
      ],
      "1215" => [
        "Western Area Power Administration",
        "Bonneville Power Administration",
        "Oak Ridge National Laboratory",
        "U.S. Army Corps of Engineers",
        "Department of Energy",
        "Water Power Technologies Office",
        "NASA Tournament Lab"
      ],
      "1219" => [
        "Army Futures Command (AFC)",
        "The Office of the United States Assistant Secretary of the Army for Acquisition, Logistics, and Technology (ASA(ALT))",
        "The U.S. Army Combat Capabilities Development Command (DEVCOM)",
        "AFWERX",
        "The U.S. Office of Naval Research Global (ONR Global)",
        "AFC Artificial Intelligence (AI)"
      ],
      "1271" => [
        "Program Executive Office for Intelligence Electronic Warfare & Sensors (PEO IEW&S)",
        "Project Manager Positioning Navigation & Timing (PM PNT)",
        "U.S. Army Combat Capabilities Development Command (DEVCOM)",
        "The C5ISR (Command, Control, Computers, Communications, Cyber, Intelligence, Surveillance and Reconnaissance) Center"
      ]
    }
  end

  def agency_map do
    %{
      "U.S. Army" => "Army",
      "NASA" => "National Aeronautics and Space Administration",
      "U.S. Air Force" => "Air Force",
      "U.S. Department of Energy" => "Department of Energy",
      "U.S. Environmental Protection Agency" => "Environmental Protection Agency",
      "National ReNEWable Energy Laboratory" => "Under Secretary of Science",
      "Office of Energy Efficiency & ReNEWable Energy" => "Under Secretary of Science",
      # "Agency for International Development" => "U.S. Agency for International Development",
      # Bureau of the Census
      "EAI" => %{"parent" => "Department of Commerce", "component" => "Bureau of the Census"},
      "U.S. Census Bureau" => %{
        "parent" => "Department of Commerce",
        "component" => "Bureau of the Census"
      },
      # Corporation for National and Community Service
      # "Department of State" => "Corporation for National and Community Service",
      # "International Assistance Programs" => "Corporation for National and Community Service",
      # Department of Agriculture
      "U.S. Department of Agriculture" => "Department of Agriculture",
      "US Department of Agriculture (USDA)" => "Department of Agriculture",
      "USDA" => "Department of Agriculture",
      # Department of Agriculture - Research, Education, and Economics
      "Department of Agriculture - National Institute of Food and Agriculture" => %{
        "parent" => "Department of Agriculture",
        "component" => "Research, Education, and Economics"
      },
      "U.S. Department of Agriculture - National Institute of Food and Agriculture" => %{
        "parent" => "Department of Agriculture",
        "component" => "Research, Education, and Economics"
      },
      "US Department of Agriculture (USDA), Agricultural Research Service" => %{
        "parent" => "Department of Agriculture",
        "component" => "Research, Education, and Economics"
      },
      "Agricultural Research Service" => %{
        "parent" => "Department of Agriculture",
        "component" => "Research, Education, and Economics"
      },
      "National Institute of Food and Agriculture" => %{
        "parent" => "Department of Agriculture",
        "component" => "Research, Education, and Economics"
      },
      # Department of Agriculture - Food, Nutrition and Consumer Services
      "Department of Agriculture - Food and Nutrition Service" => %{
        "parent" => "Department of Agriculture",
        "component" => "Food, Nutrition, and Consumer Services"
      },
      "Food and Nutrition Service" => %{
        "parent" => "Department of Agriculture",
        "component" => "Food, Nutrition, and Consumer Services"
      },
      # Department of Agriculture - Forest Service
      "Forest Service" => %{
        "parent" => "Department of Agriculture",
        "component" => "Forest Service"
      },
      # Department of Commerce
      "Dept of Commerce" => "Department of Commerce",
      # Department of Defense
      "Department of Defense - National Guard Bureau" => %{"parent" => "Department of Defense"},
      "Department of Defense - Combating Terrorism Technical Support Office (CTTSO)" => %{
        "parent" => "Department of Defense"
      },
      "Department of Defense - Irregular Warfare Technical Support Directorate (IWTSD)" => %{
        "parent" => "Department of Defense"
      },
      "National Guard Bureau" => %{"parent" => "Department of Defense"},
      "Department of Defense (DoD)" => "Department of Defense",
      "Joint AI Center (DoD)" => "Department of Defense",
      "Strategic Environmental Research and Development Program" => "Department of Defense",
      "U.S. Department of Defense" => "Department of Defense",
      # Department of Defense - Army
      "Combat Capabilities Development Center - Ground Vehicle Systems Center (CCDC/GVSC)" => %{
        "parent" => "Department of Defense",
        "component" => "Army"
      },
      "Next Generation Combat Vehicle - Cross Functional Team (NGCV-CFT)" => %{
        "parent" => "Department of Defense",
        "component" => "Army"
      },
      "Corps of Engineers-Civil Works" => %{
        "parent" => "Department of Defense",
        "component" => "Army"
      },
      "Corps of Engineers--Civil Works" => %{
        "parent" => "Department of Defense",
        "component" => "Army"
      },
      "Corps of Engineers - Civil Works" => %{
        "parent" => "Department of Defense",
        "component" => "Army"
      },
      "Department of Defense - Department of Army, HQ, M&RA, Army Enterprise Marketing Office" =>
        %{"parent" => "Department of Defense", "component" => "Army"},
      "US Army" => %{"parent" => "Department of Defense", "component" => "Army"},
      "Army Futures Command (AFC)" => %{
        "parent" => "Department of Defense",
        "component" => "Army"
      },
      "Army Corps of Engineers" => %{"parent" => "Department of Defense", "component" => "Army"},
      "The U.S. Army Combat Capabilities Development Command (DEVCOM)" => %{
        "parent" => "Department of Defense",
        "component" => "Army"
      },
      "U.S. Army Corps of Engineers" => %{
        "parent" => "Department of Defense",
        "component" => "Army"
      },
      "1st Cavalry Division (1CD)" => %{
        "parent" => "Department of Defense",
        "component" => "Army"
      },
      "AFC Artificial Intelligence (AI)" => %{
        "parent" => "Department of Defense",
        "component" => "Army"
      },
      # Department of Defense - Air Force
      "Department of Defense - US Air Force  & US Space Force" => %{
        "parent" => "Department of Defense",
        "component" => "Air Force"
      },
      "Department of Defense - Air Force Research Lab" => %{
        "parent" => "Department of Defense",
        "component" => "Air Force"
      },
      "AFWERX" => %{"parent" => "Department of Defense", "component" => "Air Force"},
      "Air Force Air University" => %{
        "parent" => "Department of Defense",
        "component" => "Air Force"
      },
      "Air Force Research Lab" => %{
        "parent" => "Department of Defense",
        "component" => "Air Force"
      },
      "Air Force Research Laboratory" => %{
        "parent" => "Department of Defense",
        "component" => "Air Force"
      },
      "Air University" => %{"parent" => "Department of Defense", "component" => "Air Force"},
      "US Air Force  & US Space Force" => %{
        "parent" => "Department of Defense",
        "component" => "Air Force"
      },
      # Department of Defense - Defense Digital Service
      "Defense Digital Service" => %{
        "parent" => "Department of Defense",
        "component" => "Defense Digital Service"
      },
      # Department of Defense - National Geospatial Intelligence Agency
      "National Geospatial-Intelligence Agency (NGA)" => %{
        "parent" => "Department of Defense",
        "component" => "National Geospatial Intelligence Agency"
      },
      "Intelligence Agency (NGA)" => %{
        "parent" => "Department of Defense",
        "component" => "National Geospatial Intelligence Agency"
      },
      "NGA" => %{
        "parent" => "Department of Defense",
        "component" => "National Geospatial Intelligence Agency"
      },
      "National Geospatial Intelligence Agency" => %{
        "parent" => "Department of Defense",
        "component" => "National Geospatial Intelligence Agency"
      },
      # Department of Defense - National Security Agency
      "National Security Agency" => %{
        "parent" => "Department of Defense",
        "component" => "National Geospatial Intelligence Agency"
      },
      # Department of Defense - Navy
      "Naval Undersea Warfare Center Division Newport" => %{
        "parent" => "Department of Defense",
        "component" => "Navy"
      },
      "Department of Defense, Naval Undersea Warfare Center, Division Newport (NUWCDIVNPT)" => %{
        "parent" => "Department of Defense",
        "component" => "Navy"
      },
      "Naval Surface Warfare Center – Crane, Division (NSWC-CR)" => %{
        "parent" => "Department of Defense",
        "component" => "Navy"
      },
      "Department of Defense - Department of the Navy, Naval Information Warfare Center Pacific" =>
        %{"parent" => "Department of Defense", "component" => "Navy"},
      "Department of Defense - U.S. Marine Corps" => %{
        "parent" => "Department of Defense",
        "component" => "Navy"
      },
      "Department of Defense - Naval Information Warfare Systems Command" => %{
        "parent" => "Department of Defense",
        "component" => "Navy"
      },
      "Department of Defense - Naval Sea Systems Command" => %{
        "parent" => "Department of Defense",
        "component" => "Navy"
      },
      "Department of Defense - U.S. Navy" => %{
        "parent" => "Department of Defense",
        "component" => "Navy"
      },
      "Chief of Information (CHINFO)" => %{
        "parent" => "Department of Defense",
        "component" => "Navy"
      },
      "Department of Defense, Department of the Navy, Naval Information Warfare Systems Command (NAVWAR)" =>
        %{"parent" => "Department of Defense", "component" => "Navy"},
      "Department of Defense, Naval Undersea Warfare Center, Division NEWport (NUWCDIVNPT)" => %{
        "parent" => "Department of Defense",
        "component" => "Navy"
      },
      "Department of Defense, Office of Naval Research, Naval Information Warfare Center Pacific" =>
        %{"parent" => "Department of Defense", "component" => "Navy"},
      "Department of the Navy, Naval Information Warfare Center Pacific" => %{
        "parent" => "Department of Defense",
        "component" => "Navy"
      },
      "Naval Accelerator (NavalX)" => %{
        "parent" => "Department of Defense",
        "component" => "Navy"
      },
      "Naval Air Systems Command" => %{"parent" => "Department of Defense", "component" => "Navy"},
      "Naval Air Warfare Center Aircraft Division (NAWCAD)" => %{
        "parent" => "Department of Defense",
        "component" => "Navy"
      },
      "Naval Information Warfare Center (NIWC), Atlantic" => %{
        "parent" => "Department of Defense",
        "component" => "Navy"
      },
      "Naval Information Warfare Centers Atlantic" => %{
        "parent" => "Department of Defense",
        "component" => "Navy"
      },
      "Naval Information Warfare Centers Pacific" => %{
        "parent" => "Department of Defense",
        "component" => "Navy"
      },
      "Naval Information Warfare Centers Pacific and Atlantic" => %{
        "parent" => "Department of Defense",
        "component" => "Navy"
      },
      "Naval Information Warfare Systems Command" => %{
        "parent" => "Department of Defense",
        "component" => "Navy"
      },
      "Naval Research Laboratory (NRL)" => %{
        "parent" => "Department of Defense",
        "component" => "Navy"
      },
      "Naval Sea Systems Command" => %{"parent" => "Department of Defense", "component" => "Navy"},
      "Naval Sea Systems Command Technology Office" => %{
        "parent" => "Department of Defense",
        "component" => "Navy"
      },
      "Naval STEM Coordination Office" => %{
        "parent" => "Department of Defense",
        "component" => "Navy"
      },
      "Naval Surface Warfare Center – Crane, Division (NSWC" => %{
        "parent" => "Department of Defense",
        "component" => "Navy"
      },
      "Naval Undersea Warfare Center Division NEWport" => %{
        "parent" => "Department of Defense",
        "component" => "Navy"
      },
      "NavalX Midwest Tech Bridge" => %{
        "parent" => "Department of Defense",
        "component" => "Navy"
      },
      "Navy and Marine Corps Small Tactical Unmanned Aircraft Systems (STUAS)" => %{
        "parent" => "Department of Defense",
        "component" => "Navy"
      },
      "Navy Cyber Warfare Development Center" => %{
        "parent" => "Department of Defense",
        "component" => "Navy"
      },
      "Office of Naval Research" => %{"parent" => "Department of Defense", "component" => "Navy"},
      "Office of Naval Research Science and Technology (ONR)" => %{
        "parent" => "Department of Defense",
        "component" => "Navy"
      },
      "Office of the Navy" => %{"parent" => "Department of Defense", "component" => "Navy"},
      "PEO C4I" => %{"parent" => "Department of Defense", "component" => "Navy"},
      "U.S. Fleet Forces (USFF)" => %{"parent" => "Department of Defense", "component" => "Navy"},
      "U.S. Marine Corps" => %{"parent" => "Department of Defense", "component" => "Navy"},
      "U.S. Navy" => %{"parent" => "Department of Defense", "component" => "Navy"},
      "U.S. Navy Facilities Engineering Command" => %{
        "parent" => "Department of Defense",
        "component" => "Navy"
      },
      # Department of Defense - Under Secretary of Defense Acquisition and Sustainment
      "Department of Defense - Office of the Secretary of Defense (Acquisition & Sustainment)" =>
        %{
          "parent" => "Department of Defense",
          "component" => "Under Secretary of Defense Acquisition and Sustainment"
        },
      # Department of Defense - Under Secretary of Defense for Research and Engineering
      "U.S. Department of Defense, National Security Innovation Network" => %{
        "parent" => "Department of Defense",
        "component" => "Under Secretary of Defense for Research and Engineering"
      },
      "National Security Innovation Network" => %{
        "parent" => "Department of Defense",
        "component" => "Under Secretary of Defense for Research and Engineering"
      },
      "National Security Innovation Network (DOD)" => %{
        "parent" => "Department of Defense",
        "component" => "Under Secretary of Defense for Research and Engineering"
      },
      # Office of the Director of National Intelligence
      "Office of Director of National Intelligence" =>
        "Office of the Director of National Intelligence",
      # Office of the Director of National Intelligence - Intelligence Advanced Research Project Activity
      "Office of Director of National Intelligence - Intelligence Advanced Research Project Activity" =>
        %{
          "parent" => "Office of the Director of National Intelligence",
          "component" => "Intelligence Advanced Research Project Activity"
        },
      # Department of Education
      "Department of Education (ED)" => "Department of Education",
      "U.S. Department of Education" => "Department of Education",
      # Department of Energy
      "Department of Energy (DOE)" => "Department of Energy",
      "Dept of Energy" => "Department of Energy",
      # Department of Energy - Under Secretary for Nuclear Security
      "National Nuclear Security Administration" => %{
        "parent" => "Department of Energy",
        "component" => "Under Secretary for Nuclear Security"
      },
      # Department of Energy - Under Secretary of Science
      "Department of Energy - Office of Energy Efficiency & Renewable Energy" => %{
        "parent" => "Department of Energy",
        "component" => "Under Secretary of Science"
      },
      "Cybersecurity Research Group" => %{
        "parent" => "Department of Energy",
        "component" => "Under Secretary of Science"
      },
      "National Renewable Energy Laboratory" => %{
        "parent" => "Department of Energy",
        "component" => "Under Secretary of Science"
      },
      "Oak Ridge National Lab" => %{
        "parent" => "Department of Energy",
        "component" => "Under Secretary of Science"
      },
      "Oak Ridge National Laboratories (ORNL)" => %{
        "parent" => "Department of Energy",
        "component" => "Under Secretary of Science"
      },
      "Office of Energy Efficiency & Renewable Energy" => %{
        "parent" => "Department of Energy",
        "component" => "Under Secretary of Science"
      },
      # Department of Energy - Under Secretary of Energy
      "Department of Energy's Water Power Technologies Office" => %{
        "parent" => "Department of Energy",
        "component" => "Under Secretary of Energy"
      },
      "Department of Energy - Water Power Technologies Office" => %{
        "parent" => "Department of Energy",
        "component" => "Under Secretary of Energy"
      },
      "Department of Energy - Office of Technology Transitions" => %{
        "parent" => "Department of Energy",
        "component" => "Under Secretary of Energy"
      },
      "Department of Energy - Solar Energy Technologies Office" => %{
        "parent" => "Department of Energy",
        "component" => "Under Secretary of Energy"
      },
      "Water Power Technologies Office" => %{
        "parent" => "Department of Energy",
        "component" => "Under Secretary of Energy"
      },
      # Department of Health and Human Services
      "Department of Health & Human Services" => "Department of Health and Human Services",
      "Department of Health and Human Services (HHS)" =>
        "Department of Health and Human Services",
      # Department of Health and Human Services - Administration for Community Living
      "Department of Health and Humans Services - Administration for Community Living" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "Administration for Community Living"
      },
      # Department of Health and Human Services - Agency for Healthcare Research and Quality
      "Agency for Healthcare Research and Quality" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "Agency for Healthcare Research and Quality"
      },
      # Department of Health and Human Services - Centers for Disease Control and Prevention
      "Department of State - Office of Occupational Health and Wellness" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "Centers for Disease Control and Prevention"
      },
      "Centers for Disease Control and Prevention - National Institute for Occupational Safety and Health (NIOSH)" =>
        %{
          "parent" => "Department of Health and Human Services",
          "component" => "Centers for Disease Control and Prevention"
        },
      "Department of Health & Human Services - Centers for Disease Control & Prevention" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "Centers for Disease Control and Prevention"
      },
      "CDC" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "Centers for Disease Control and Prevention"
      },
      "Centers for Disease Control & Prevention" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "Centers for Disease Control and Prevention"
      },
      "Centers for Disease Control and Prevention" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "Centers for Disease Control and Prevention"
      },
      "National Center for Environmental Health" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "Centers for Disease Control and Prevention"
      },
      "National Institute for Occupational Safety and Health (NIOSH)" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "Centers for Disease Control and Prevention"
      },
      # Department of Health and Human Services - Food and Drug Administration
      "Food and Drug Administration" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "Food and Drug Administration"
      },
      "Food and Drug Administration (FDA)" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "Food and Drug Administration"
      },
      "U.S. Food and Drug Administration" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "Food and Drug Administration"
      },
      # Department of Health and Human Services - Indian Health Service
      "Indian Health Service" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "Indian Health Service"
      },
      # Department of Health and Human Services - Resources and Services Administration
      "Health Resources and Services Administration, Maternal and Child Health Bureau" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "Health Resources and Services Administration"
      },
      # Department of Health and Human Services - National Institutes of Health
      "National Institutes of Health - National Institute on Minority Health and Health Disparities" =>
        %{
          "parent" => "Department of Health and Human Services",
          "component" => "National Institutes of Health"
        },
      "National Institute of Health (NIH) - National Heart, Lung & Blood Institute (NHLBI)" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "National Institutes of Health"
      },
      "Department of Health and Human Services - National Institute of Health" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "National Institutes of Health"
      },
      "Department of Health and Human Services - Health Resources and Services Administration, Maternal and Child Health Bureau" =>
        %{
          "parent" => "Department of Health and Human Services",
          "component" => "National Institutes of Health"
        },
      "Department of Commerce - National Institute of Standards and Technology, Public Safety Communications Research (PSCR) Division" =>
        %{
          "parent" => "Department of Health and Human Services",
          "component" => "National Institutes of Health"
        },
      "Department of Health and Human Services, National Institutes of Health, National Institute of Biomedical Imaging and Bioengineering" =>
        %{
          "parent" => "Department of Health and Human Services",
          "component" => "National Institutes of Health"
        },
      "Department of Health and Human Services, National Institutes of Health, National Institute on Drug Abuse" =>
        %{
          "parent" => "Department of Health and Human Services",
          "component" => "National Institutes of Health"
        },
      "HHS/NIH/National Institute of Allergy and Infectious Diseases" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "National Institutes of Health"
      },
      "National Heart, Lung & Blood Institute (NHLBI)" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "National Institutes of Health"
      },
      "National Institute of Allergy and Infectious Disease" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "National Institutes of Health"
      },
      "National Institute of Diabetes and Digestive and Kidney Diseases" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "National Institutes of Health"
      },
      "National Institute of Health" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "National Institutes of Health"
      },
      "National Institutes of Health" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "National Institutes of Health"
      },
      "National Institute of Health (NIH)" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "National Institutes of Health"
      },
      "National Institute of Minority Health and Health Disparities (NIMHD)" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "National Institutes of Health"
      },
      "National Institute on Drug Abuse" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "National Institutes of Health"
      },
      "National Institute on Minority Health and Health Disparities" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "National Institutes of Health"
      },
      "NIH Office of the Director" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "National Institutes of Health"
      },
      # Department of Health and Human Services - Office of the Secretary
      "Department of Health and Human Services - Office of the Assistant Secretary for Preparedness and Response" =>
        %{
          "parent" => "Department of Health and Human Services",
          "component" => "Office of the Secretary"
        },
      "Department of Health and Human Services - Office of the National Coordination for Health Information Technology" =>
        %{
          "parent" => "Department of Health and Human Services",
          "component" => "Office of the Secretary"
        },
      "Department of Health and Human Services - Office of the Assistant Secretary for Health (OASH), Office on Women's Health (OWH)" =>
        %{
          "parent" => "Department of Health and Human Services",
          "component" => "Office of the Secretary"
        },
      "Department of Health & Human Services - Office of National Coordinator for Health Information Technology" =>
        %{
          "parent" => "Department of Health and Human Services",
          "component" => "Office of the Secretary"
        },
      "Department of Health and Human Services - Biomedical Advanced Research and Development Authority (BARDA)" =>
        %{
          "parent" => "Department of Health and Human Services",
          "component" => "Office of the Secretary"
        },
      "Department of Health & Human Services - Office of Minority Health" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "Office of the Secretary"
      },
      "Biomedical Advanced Research and Development Authority (BARDA)" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "Office of the Secretary"
      },
      "Department of Health and Human Services (HHS) – Office of the Assistant Secretary for Health (OASH)" =>
        %{
          "parent" => "Department of Health and Human Services",
          "component" => "Office of the Secretary"
        },
      "Department of Health and Human Services Office of the Assistant Secretary for Health" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "Office of the Secretary"
      },
      "Department of Health and Human Services - Office of the Assistant Secretary for Health (OASH), Office of Women's Health (OWH)" =>
        %{
          "parent" => "Department of Health and Human Services",
          "component" => "Office of the Secretary"
        },
      "HHS/Biomedical Advanced Research and Development Authority" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "Office of the Secretary"
      },
      "OASH InnovationX; HHS Office of the Chief Data Officer (OCDO); Centers for Disease Control and Prevention (CDC)" =>
        %{
          "parent" => "Department of Health and Human Services",
          "component" => "Office of the Secretary"
        },
      "Office of Infectious Disease and HIV/AIDS Policy (OIDP)" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "Office of the Secretary"
      },
      "Office of Minority Health" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "Office of the Secretary"
      },
      "Office of National Coordinator for Health Information Technology" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "Office of the Secretary"
      },
      "Office of the Assistant Secretary for Health (OASH)" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "Office of the Secretary"
      },
      "Office of the Assistant Secretary for Health (OASH), Office on Women's Health (OWH)" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "Office of the Secretary"
      },
      "Office of the Assistant Secretary for Preparedness and Response" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "Office of the Secretary"
      },
      "Office of the National Coordination for Health Information Technology" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "Office of the Secretary"
      },
      # Department of Homeland Security
      "Department of Homeland Security (DHS)" => "Department of Homeland Security",
      "U.S. Department of Homeland Security" => "Department of Homeland Security",
      # Department of Homeland Security - Science and Technology Directorate
      "Department of Homeland Security - Science and Technology" => %{
        "parent" => "Department of Homeland Security",
        "component" => "Science and Technology Directorate"
      },
      "Department of Homeland Security Science & Technology Directorate" => %{
        "parent" => "Department of Homeland Security",
        "component" => "Science and Technology Directorate"
      },
      # Department of Homeland Security - United States Customs and Border Protection
      "U.S. Customs and Border Protection" => %{
        "parent" => "Department of Homeland Security",
        "component" => "United States Customs and Border Protection"
      },
      # Department of Housing and Urban Development
      "HUD" => "Department of Housing and Urban Development",
      "U.S. Department of Housing and Urban Development" =>
        "Department of Housing and Urban Development",
      # Department of Justice
      "Department of Justice - National Institute of Justice" => %{
        "parent" => "Department of Justice"
      },
      "National Institute of Justice" => "Department of Justice",
      # Department of Labor
      "Labor" => "Department of Labor",
      # Department of State
      "Department of State (State)" => "Department of State",
      "Department of State / Boldline Accelerator" => "Department of State",
      # "International Assistance Programs" => "Department of State",
      # Department of the Interior
      "Dept of Interior" => "Department of the Interior",
      "Department of Interior (DOI)" => "Department of the Interior",
      "Department of the Interior Office of Native Hawaiian Relations" =>
        "Department of the Interior",
      "U.S. Department of the Interior" => "Department of the Interior",
      # Department of the Interior - National Invasive Species Council Secretariat
      "National Invasive Species Council Secretariat" => %{
        "parent" => "Department of the Interior",
        "component" => "National Invasive Species Council Secretariat"
      },
      # Department of the Interior - National Park Service
      "National Park Service" => %{
        "parent" => "Department of the Interior",
        "component" => "National Park Service"
      },
      # Department of the Interior - United States Fish and Wildlife Service
      "Department of the Interior - U.S. Fish and Wildlife Service" => %{
        "parent" => "Department of the Interior",
        "component" => "United States Fish and Wildlife Service"
      },
      "U.S Fish and Wildlife Service" => %{
        "parent" => "Department of the Interior",
        "component" => "United States Fish and Wildlife Service"
      },
      # Department of the Interior - United States Geological Survey
      "Department of the Interior - U.S. Geological Survey" => %{
        "parent" => "Department of the Interior",
        "component" => "United States Geological Survey"
      },
      "Colorado Basin River Forecast Center" => %{
        "parent" => "Department of the Interior",
        "component" => "United States Geological Survey"
      },
      "U.S. Geological Survey" => %{
        "parent" => "Department of the Interior",
        "component" => "United States Geological Survey"
      },
      "U.S. Section of the International Boundary and Water Commission" => %{
        "parent" => "Department of the Interior",
        "component" => "United States Geological Survey"
      },
      "USGS" => %{
        "parent" => "Department of the Interior",
        "component" => "United States Geological Survey"
      },
      "United States Geological Survey" => %{
        "parent" => "Department of the Interior",
        "component" => "United States Geological Survey"
      },
      # Department of Transportation
      "Department of Transportation (DOT)" => "Department of Transportation",
      # Department of Transportation - Federal Aviation Administration
      "Federal Aviation Administration" => %{
        "parent" => "Department of Transportation",
        "component" => "Federal Aviation Administration"
      },
      # Department of Veterans Affairs
      "Department of Veterans Affairs - National Artificial Intelligence Institute" => %{
        "parent" => "Department of Veterans Affairs"
      },
      "Department of Veterans Affairs (VA)" => "Department of Veterans Affairs",
      "U.S. Department of Veterans Affairs" => "Department of Veterans Affairs",
      # Department of Veterans Affairs - Veterans Health Administration
      "Veterans Health Administration Innovation Ecosystem" => %{
        "parent" => "Department of Veterans Affairs",
        "component" => "Veterans Health Administration"
      },
      "VHA Innovation Ecosystem" => %{
        "parent" => "Department of Veterans Affairs",
        "component" => "Veterans Health Administration"
      },
      # Environmental Protection Agency
      "Environmental Protection Agency – Region 7" => "Environmental Protection Agency",
      "Environmental Protection Agency (EPA)" => "Environmental Protection Agency",
      "Environmental Protection Agency Regions 7 and 8" => "Environmental Protection Agency",
      "EPA" => "Environmental Protection Agency",
      # The Executive Office of the President 
      "White House" => "The Executive Office of the President",
      # The Executive Office of the President - Office of Management and Budget
      "Executive Office of the President - Office of Management and Budget" => %{
        "parent" => "The Executive Office of the President",
        "component" => "Office of Management and Budget"
      },
      # Farm Production and Conservation
      "Natural Resources Conservation Service" => %{
        "parent" => "Department of Agriculture",
        "component" => "Farm Production and Conservation"
      },
      # Federal Aviation Administration
      "Department of Transportation - Federal Aviation Administration (FAA)" => %{
        "parent" => "Department of Transportation",
        "component" => "Federal Aviation Administration"
      },
      "Federal Aviation Administration (FAA)" => %{
        "parent" => "Department of Transportation",
        "component" => "Federal Aviation Administration"
      },
      # Federal Deposit Insurance Corporation
      "FDIC Office of Inspector General" => "Federal Deposit Insurance Corporation",
      "Federal Deposit Insurance Corporation (FDIC)" => "Federal Deposit Insurance Corporation",
      # Federal Emergency Management Administration
      "FEMA" => %{
        "parent" => "Department of Homeland Security",
        "component" => "Federal Emergency Management Administration"
      },
      # Millennium Challenge Corporation
      "International Assistance Programs - Millennium Challenge Corporation" => %{
        "parent" => "Millennium Challenge Corporation"
      },
      # National Aeronautics and Space Administration
      "NASA Centennial Challenges" => "National Aeronautics and Space Administration",
      "NASA Centennial Challenges and NASA Glenn Research Center" =>
        "National Aeronautics and Space Administration",
      "NASA Centennial Challenges Program and NASA Ames Research Center" =>
        "National Aeronautics and Space Administration",
      "NASA Kennedy Space Center" => "National Aeronautics and Space Administration",
      "NASA Langley Research Center" => "National Aeronautics and Space Administration",
      "NASA Marshall Space Flight Center" => "National Aeronautics and Space Administration",
      "NASA Tournament Labs" => "National Aeronautics and Space Administration",
      "National Aeronautics and Aerospace Agency (NASA)" =>
        "National Aeronautics and Space Administration",
      "National Aeronautics and Space Administration (NASA)" =>
        "National Aeronautics and Space Administration",
      "NASA Tournament Lab" => "National Aeronautics and Space Administration",
      # National Institute of Standards and Technology
      "National Institute of Standards and Technology" => %{
        "parent" => "Department of Commerce",
        "component" => "National Institute of Standards and Technology"
      },
      "National Institute of Standards & Technology (NIST)" => %{
        "parent" => "Department of Commerce",
        "component" => "National Institute of Standards and Technology"
      },
      "National Institute of Standards and Technology (NIST)" => %{
        "parent" => "Department of Commerce",
        "component" => "National Institute of Standards and Technology"
      },
      "National Institute of Standards and Technology, Public Safety Communications Research (PSCR) Division" =>
        %{
          "parent" => "Department of Commerce",
          "component" => "National Institute of Standards and Technology"
        },
      "NIST PSCR Group" => %{
        "parent" => "Department of Commerce",
        "component" => "National Institute of Standards and Technology"
      },
      # Department of Commerce - National Oceanic and Atmospheric Administration
      "NOAA" => %{
        "parent" => "Department of Commerce",
        "component" => "National Oceanic and Atmospheric Administration"
      },
      "NOAA - National Integrated Drought Information System" => %{
        "parent" => "Department of Commerce",
        "component" => "National Oceanic and Atmospheric Administration"
      },
      "NOAA-directed U.S. Integrated Ocean Observing System" => %{
        "parent" => "Department of Commerce",
        "component" => "National Oceanic and Atmospheric Administration"
      },
      "National Oceanic and Atmospheric Administration" => %{
        "parent" => "Department of Commerce",
        "component" => "National Oceanic and Atmospheric Administration"
      },
      "National Oceanic and Atmospheric Administration (including the U.S. Integrated Ocean Observing System and the Alliance for Coastal Technologies)" =>
        %{
          "parent" => "Department of Commerce",
          "component" => "National Oceanic and Atmospheric Administration"
        },
      "NOAA Fisheries" => %{
        "parent" => "Department of Commerce",
        "component" => "National Oceanic and Atmospheric Administration"
      },
      "NOAA National Marine Fisheries Service" => %{
        "parent" => "Department of Commerce",
        "component" => "National Oceanic and Atmospheric Administration"
      },
      # National Park Service
      "Hawaii Volcanoes National Park" => %{
        "parent" => "Department of the Interior",
        "component" => "National Park Service"
      },
      # National Science Foundation
      "National Science Foundation - National Nanotechnology Coordination Office" => %{
        "parent" => "National Science Foundation"
      },
      "National Nanotechnology Coordination Office" => "National Science Foundation",
      "National Science Foundation (NSF)" => "National Science Foundation",
      # National Science Foundation - Directorate for Engineering
      "NSF Directorate for Engineering" => %{
        "parent" => "National Science Foundation",
        "component" => "Directorate for Engineering"
      },
      # National Telecommunications and Information Administration
      "First Responder Network Authority" => %{
        "parent" => "Department of Commerce",
        "component" => "National Telecommunications and Information Administration"
      },
      "First Responder Network Authority (FirstNet the Authority)" => %{
        "parent" => "Department of Commerce",
        "component" => "National Telecommunications and Information Administration"
      },
      "First Responder Network Authority (FRNA)" => %{
        "parent" => "Department of Commerce",
        "component" => "National Telecommunications and Information Administration"
      },
      # Office of Management and Budget
      "Office of Management and Budget (OMB), Office of Federal Procurement Policy (OFPP)" => %{
        "parent" => "The Executive Office of the President",
        "component" => "Office of Management and Budget"
      },
      # Small Business Administration
      "U.S. Small Business Administration" => "Small Business Administration",
      # U.S. Agency for International Development
      "International Assistance Programs - Agency for International Development" => %{
        "parent" => "U.S. Agency for International Development"
      },
      "United States Agency for International Development" =>
        "U.S. Agency for International Development",
      # Legislative Branch - House of Representatives
      "Legislative Branch - House of Representatives" => %{
        "parent" => "Legislative Branch",
        "component" => "U.S. House of Representatives"
      },
      # Legislative Branch - Library of Congress
      "Legislative Branch - Library of Congress" => %{
        "parent" => "Legislative Branch",
        "component" => "Library of Congress"
      },
      "LegislativeBranch - Library of Congress" => %{
        "parent" => "Legislative Branch",
        "component" => "Library of Congress"
      },
      # U.S. Postal Service
      "United States Postal Inspection Service" => "U.S. Postal Service",
      # TODO: FIX
      # "CDC - National Center for Environmental Health; CDC-National Institute of Occupational Safety and Health; Department of State - Office of Occupational Health and Wellness; National Institute of Standards and Technology" =>
      # %{"parent" => "FIX"},
      "International Assistance Programs - Department of State - Other" => %{"parent" => "FIX"},
      # "Program Manager Air (PMA-263)" => %{"parent" => "Program Manager Air (PMA-263)"},
      "Program Manager Air (PMA 263)" => %{
        "parent" => "Department of Defense",
        "component" => "Navy"
      },
      "National Heart, Lung, and Blood Institute" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "National Institutes of Health"
      },
      "National Heart, Lung and Blood Institute" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "National Institutes of Health"
      },
      "Fogarty International Center" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "National Institutes of Health"
      },
      "Environmental Security Technology Certification Program" => %{
        "parent" => "Department of Defense",
        "component" => "Under Secretary of Defense for Research and Engineering"
      },
      "Naval STEM Coordination Office, managed by the Office of Naval Research" => %{
        "parent" => "Department of Defense",
        "component" => "Navy"
      },
      "Members of the National Science and Technology Council Lab to Market Subcommittee: White House Office of Science and Technology Policy (OSTP)" =>
        %{
          "parent" => "The Executive Office of the President",
          "component" => "Office of Science and Technology Policy"
        },
      "Department of Commerce (NIST, NOAA)" => %{
        "parent" => "Department of Commerce",
        "component" => "National Institute of Standards and Technology"
      },
      "Commander, U.S. Fleet Forces (USFF)" => %{
        "parent" => "Department of Defense",
        "component" => "Navy"
      },
      "CDC National Center for Environmental Health" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "Centers for Disease Control and Prevention"
      },
      "CDC National Institute of Occupational Safety and Health" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "Centers for Disease Control and Prevention"
      },
      "Western Area Power Administration" => %{"parent" => "Department of Energy"},
      "Bonneville Power Administration" => %{"parent" => "Department of Energy"},
      "Oak Ridge National Laboratory" => %{
        "parent" => "Department of Energy",
        "component" => "Under Secretary of Science"
      },
      "The Office of the United States Assistant Secretary of the Army for Acquisition, Logistics, and Technology (ASA(ALT))" =>
        %{"parent" => "Department of Defense", "component" => "Army"},
      "The U.S. Office of Naval Research Global (ONR Global)" => %{
        "parent" => "Department of Defense",
        "component" => "Navy"
      },
      "The U.S. Army Rapid Capabilities and Critical Technologies Office (RCCTO)" => %{
        "parent" => "Department of Defense",
        "component" => "Army"
      },
      "U.S. Fish and Wildlife Service" => %{
        "parent" => "Department of the Interior",
        "component" => "United States Fish and Wildlife Service"
      },
      "Program Executive Office for Intelligence Electronic Warfare & Sensors (PEO IEW&S)" => %{
        "parent" => "Department of Defense",
        "component" => "Army"
      },
      "Project Manager Positioning Navigation & Timing (PM PNT)" => %{
        "parent" => "Department of Defense",
        "component" => "Army"
      },
      "U.S. Army Combat Capabilities Development Command (DEVCOM)" => %{
        "parent" => "Department of Defense",
        "component" => "Army"
      },
      "The C5ISR (Command, Control, Computers, Communications, Cyber, Intelligence, Surveillance and Reconnaissance) Center" =>
        %{"parent" => "Department of Defense", "component" => "Army"},
      "National Institute of Science and Technology" => %{
        "parent" => "Department of Commerce",
        "component" => "National Institute of Standards and Technology"
      },
      "Substance Abuse and Mental Health Services Administration" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "Substance Abuse and Mental Health Services Administration"
      },
      "Office of National Drug Control Policy" => %{
        "parent" => "The Executive Office of the President",
        "component" => "Office of National Drug Control Policy"
      },
      "Office of Occupational Health and Wellness" => %{
        "parent" => "Department of Health and Human Services",
        "component" => "Centers for Disease Control and Prevention"
      },
      "Science and Technology Directorate (DHS S&T)" => %{
        "parent" => "Department of Homeland Security",
        "component" => "Science and Technology Directorate"
      },
      "Federal Emergency Management Administration" => %{
        "parent" => "Department of Homeland Security",
        "component" => "Federal Emergency Management Agency"
      },
      # Not agencies
      # "Consumer Technology Association Foundation" => nil,
      # "Carnegie Mellon University’s Software Engineering Institute (FFRDC)" => nil,
      "Consumer Technology Association Foundation" => %{"parent" => nil},
      "Carnegie Mellon University’s Software Engineering Institute (FFRDC)" => %{"parent" => nil}
    }
  end

  @challenge_types %{
    analytics: "Analytics, visualizations, algorithms",
    business: "Business plans",
    creative: "Creative (multimedia & design)",
    ideas: "Ideas",
    nominations: "Nominations",
    scientific: "Scientific",
    software: "Software and apps",
    technology: "Technology demonstration and hardware"
  }

  def type_map do
    %{
      "Analytics, Visualizations and algorithms" => @challenge_types.analytics,
      "Analytics, visualization, algorithms" => @challenge_types.analytics,
      "Analytics, visualization, and algorithms" => @challenge_types.analytics,
      "Analytics, visualizations and algorithms" => @challenge_types.analytics,
      "Analytics, visualizations, algorithms" => @challenge_types.analytics,
      "Analytics, visualizations, and algorithms" => @challenge_types.analytics,
      "Analytics, visulizations, algorithms" => @challenge_types.analytics,
      "Business Plans" => @challenge_types.business,
      "Business plans" => @challenge_types.business,
      "Creative" => @challenge_types.creative,
      "Creative (design & multimedia)" => @challenge_types.creative,
      "Creative (multimedia & design)" => @challenge_types.creative,
      "Creative (multimedia and design)" => @challenge_types.creative,
      "Ideas" => @challenge_types.ideas,
      "Nominations" => @challenge_types.nominations,
      "Scientific" => @challenge_types.scientific,
      "Software" => @challenge_types.software,
      "Software and apps" => @challenge_types.software,
      "Software/Apps" => @challenge_types.software,
      "Tech demonstration and hardware" => @challenge_types.technology,
      "Technology" => @challenge_types.technology,
      "Technology demonstration" => @challenge_types.technology,
      "Technology demonstration / hardware" => @challenge_types.technology,
      "Technology demonstration and hardware" => @challenge_types.technology,
      "Virtual Reality" => @challenge_types.analytics,
      "analytics, visualizations, algorithms" => @challenge_types.analytics,
      "creative (multimedia & design)" => @challenge_types.creative,
      "ideas" => @challenge_types.ideas,
      "software and apps" => @challenge_types.software,
      "technology demonstration" => @challenge_types.technology,
      "technology demonstration and hardware" => @challenge_types.technology,
      "Creative (multimedia and design), scientific" => [
        @challenge_types.creative,
        @challenge_types.scientific
      ],
      "Software and apps, creative (multimedia & design)" => [
        @challenge_types.software,
        @challenge_types.creative
      ],
      "Ideas, Technology demonstration and hardware" => [
        @challenge_types.ideas,
        @challenge_types.technology
      ],
      "Ideation, Technology demonstration/hardware" => [
        @challenge_types.ideas,
        @challenge_types.technology
      ],
      "Technology demonstration and hardware, Scientific, Software and apps" => [
        @challenge_types.technology,
        @challenge_types.scientific,
        @challenge_types.software
      ],
      "Ideation, Technology Demonstration/Hardware" => [
        @challenge_types.ideas,
        @challenge_types.technology
      ],
      "Ideas, scientific" => [@challenge_types.ideas, @challenge_types.scientific]
    }
  end
end
