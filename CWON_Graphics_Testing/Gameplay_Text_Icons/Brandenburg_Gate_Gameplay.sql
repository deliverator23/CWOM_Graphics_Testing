

INSERT INTO Types (Type, Kind) VALUES ('BUILDING_BRANDENBURG_GATE', 'KIND_BUILDING');

INSERT INTO Buildings (BuildingType, Name, Description, PrereqTech, Cost, AdvisorType, MaxWorldInstances, IsWonder, RequiresPlacement, Quote, AdjacentDistrict)
VALUES ('BUILDING_BRANDENBURG_GATE', 'LOC_BUILDING_BRANDENBURG_GATE_NAME', 'LOC_BUILDING_BRANDENBURG_GATE_DESCRIPTION', 'TECH_BANKING', 920, 'ADVISOR_CULTURE', '1', 1, 1, 'LOC_BUILDING_BRANDENBURG_GATE_QUOTE', 'DISTRICT_CITY_CENTER');

--INSERT INTO BuildingPrereqs (Building, PrereqBuilding) VALUES ('BUILDING_BRANDENBURG_GATE', 'BUILDING_BANK');

--INSERT INTO Building_YieldChanges (BuildingType, YieldType, YieldChange) VALUES  ('BUILDING_BRANDENBURG_GATE', 'YIELD_GOLD', 2);

INSERT INTO Building_ValidTerrains (BuildingType, TerrainType)
VALUES
  (
    'BUILDING_BRANDENBURG_GATE', 'TERRAIN_GRASS'
  ),
  (
    'BUILDING_BRANDENBURG_GATE', 'TERRAIN_PLAINS'
  ),
  (
    'BUILDING_BRANDENBURG_GATE', 'TERRAIN_TUNDRA'
  );


-- 1 free Great General appears near the city where the wonder was built
INSERT INTO Modifiers (ModifierId, ModifierType,  RunOnce, Permanent)
VALUES ('BRANDENBURG_GRANT_GENERAL', 'MODIFIER_SINGLE_CITY_GRANT_GREAT_PERSON_CLASS_IN_CITY',  1, 1);

INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES ('BRANDENBURG_GRANT_GENERAL', 'GreatPersonClassType', 'GREAT_PERSON_CLASS_GENERAL');
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES ('BRANDENBURG_GRANT_GENERAL', 'Amount', '1');

INSERT INTO BuildingModifiers (BuildingType, ModifierId) VALUES ('BUILDING_BRANDENBURG_GATE', 'BRANDENBURG_GRANT_GENERAL');



--Any City with Art Museum yields + 1 Culture
--INSERT INTO Requirements (RequirementId, RequirementType) VALUES ('REQUIRES_CITY_HAS_ART_MUSEUM', 'REQUIREMENT_CITY_HAS_BUILDING');

--INSERT INTO RequirementArguments (RequirementId, Name, Value) VALUES ('REQUIRES_CITY_HAS_ART_MUSEUM', 'BuildingType', 'BUILDING_MUSEUM_ART');

--INSERT INTO RequirementSets (RequirementSetId, RequirementSetType) VALUES ('CITY_HAS_ART_MUSEUM_REQUIREMENTS', 'REQUIREMENTSET_TEST_ANY');

--INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId) VALUES ('CITY_HAS_ART_MUSEUM_REQUIREMENTS', 'REQUIRES_CITY_HAS_ART_MUSEUM');


--INSERT INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId)
--VALUES ('UFFIZI_ART_MUSEUM_CULTURE_MODIFIER', 'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_CHANGE', 'CITY_HAS_ART_MUSEUM_REQUIREMENTS');


--INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES ('UFFIZI_ART_MUSEUM_CULTURE_MODIFIER', 'YieldType', 'YIELD_CULTURE');

--INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES ('UFFIZI_ART_MUSEUM_CULTURE_MODIFIER', 'Amount', '1');

--INSERT INTO BuildingModifiers (BuildingType, ModifierId) VALUES ('BUILDING_BRANDENBURG_GATE', 'UFFIZI_ART_MUSEUM_CULTURE_MODIFIER');