--- START OF FILE states.txt ---
INSERT INTO
    "public"."states" ("id", "name", "country_id")
VALUES
    (
        '1',
        'Southern Nations, Nationalities, and Peoples'' Region',
        '70'
    ), -- Fixed escaping of single quote
    ('2', 'Somali Region', '70'),
    ('3', 'Amhara Region', '70'),
    ('4', 'Tigray Region', '70'),
    ('5', 'Oromia Region', '70'),
    ('6', 'Afar Region', '70'),
    ('7', 'Harari Region', '70'),
    ('8', 'Dire Dawa', '70'),
    ('9', 'Benishangul-Gumuz Region', '70'),
    ('10', 'Gambela Region', '70'),
    ('11', 'Addis Ababa', '70'),
    ('12', 'Petnjica Municipality', '147'),
    ('13', 'Bar Municipality', '147'),
    ('14', 'Danilovgrad Municipality', '147'),
    ('15', 'Rožaje Municipality', '147'), -- Rožaje has 'ž'
    ('16', 'Plužine Municipality', '147'), -- Plužine has 'ž'
    ('17', 'Nikšić Municipality', '147'), -- Nikšić has 'š' and 'ć'
    ('18', 'Šavnik Municipality', '147'), -- Šavnik has 'Š'
    ('19', 'Plav Municipality', '147'),
    ('20', 'Pljevlja Municipality', '147'),
    ('21', 'Berane Municipality', '147'),
    ('22', 'Mojkovac Municipality', '147'),
    ('23', 'Andrijevica Municipality', '147'),
    ('24', 'Gusinje Municipality', '147'),
    ('25', 'Bijelo Polje Municipality', '147'),
    ('26', 'Kotor Municipality', '147'),
    ('27', 'Podgorica Municipality', '147'),
    ('28', 'Old Royal Capital Cetinje', '147'),
    ('29', 'Tivat Municipality', '147'),
    ('30', 'Budva Municipality', '147'),
    ('31', 'Kolašin Municipality', '147'), -- Kolašin has 'š'
    ('32', 'Žabljak Municipality', '147'), -- Žabljak has 'Ž'
    ('33', 'Ulcinj Municipality', '147'),
    ('34', 'Kunene Region', '152'),
    ('35', 'Kavango West Region', '152'),
    ('36', 'Kavango East Region', '152'),
    ('37', 'Oshana Region', '152'),
    ('38', 'Hardap Region', '152'),
    ('39', 'Omusati Region', '152'),
    ('40', 'Ohangwena Region', '152'),
    ('41', 'Omaheke Region', '152'),
    ('42', 'Oshikoto Region', '152'),
    ('43', 'Erongo Region', '152'),
    ('44', 'Khomas Region', '152'),
    ('45', 'ǁKaras Region', '152'), -- Changed Karas to ǁKaras (official name with click consonant, assuming UTF-8 support)
    ('46', 'Otjozondjupa Region', '152'),
    ('47', 'Zambezi Region', '152'),
    ('48', 'Ashanti Region', '83'),
    ('49', 'Western Region', '83'),
    ('50', 'Eastern Region', '83'),
    ('51', 'Northern Region', '83'),
    ('52', 'Central Region', '83'),
    ('53', 'Bono-Ahafo Region', '83'), -- Changed Brong-Ahafo to Bono-Ahafo (split in 2019, this is common parent name)
    ('54', 'Greater Accra Region', '83'),
    ('55', 'Upper East Region', '83'),
    ('56', 'Volta Region', '83'),
    ('57', 'Upper West Region', '83'),
    ('58', 'San Marino', '192'), -- City of San Marino
    ('59', 'Acquaviva', '192'),
    ('60', 'Chiesanuova', '192'),
    ('61', 'Borgo Maggiore', '192'),
    ('62', 'Faetano', '192'),
    ('63', 'Montegiardino', '192'),
    ('64', 'Domagnano', '192'),
    ('65', 'Serravalle', '192'),
    ('66', 'Fiorentino', '192'),
    ('67', 'Tillabéri Region', '160'), -- Tillabéri has 'é'
    ('68', 'Dosso Region', '160'),
    ('69', 'Zinder Region', '160'),
    ('70', 'Maradi Region', '160'),
    ('71', 'Agadez Region', '160'),
    ('72', 'Diffa Region', '160'),
    ('73', 'Tahoua Region', '160'),
    ('74', 'Mqabba', '135'),
    ('75', 'San Ġwann', '135'), -- Ġwann has 'Ġ'
    ('76', 'Żurrieq', '135'), -- Żurrieq has 'Ż'
    ('77', 'Luqa', '135'),
    ('78', 'Marsaxlokk', '135'),
    ('79', 'Qala', '135'),
    ('80', 'Żebbuġ Malta', '135'), -- Żebbuġ has 'Ż' and 'ġ'
    ('81', 'Xgħajra', '135'), -- Xgħajra has 'Xgħ'
    ('82', 'Kirkop', '135'),
    ('83', 'Rabat', '135'),
    ('84', 'Floriana', '135'),
    ('85', 'Żebbuġ Gozo', '135'), -- Żebbuġ has 'Ż' and 'ġ'
    ('86', 'Swieqi', '135'),
    ('87', 'Saint Lawrence', '135'),
    ('88', 'Birżebbuġa', '135'), -- Birżebbuġa has 'ż' and 'ġ'
    ('89', 'Mdina', '135'),
    ('90', 'Santa Venera', '135'),
    ('91', 'Kerċem', '135'), -- Kerċem has 'ċ'
    ('92', 'Għarb', '135'), -- Għarb has 'Għ'
    ('93', 'Iklin', '135'),
    ('94', 'Santa Luċija', '135'), -- Luċija has 'ċ'
    ('95', 'Valletta', '135'),
    ('96', 'Msida', '135'),
    ('97', 'Birkirkara', '135'),
    ('98', 'Siġġiewi', '135'), -- Siġġiewi has 'ġġ'
    ('99', 'Kalkara', '135'),
    ('100', 'St. Julian''s', '135'), -- Fixed escaping of single quote
    ('101', 'Victoria', '135'),
    ('102', 'Mellieħa', '135'), -- Mellieħa has 'ħ'
    ('103', 'Tarxien', '135'),
    ('104', 'Sliema', '135'),
    ('105', 'Ħamrun', '135'), -- Ħamrun has 'Ħ'
    ('106', 'Għasri', '135'), -- Għasri has 'Għ'
    ('107', 'Birgu', '135'),
    ('108', 'Balzan', '135'),
    ('109', 'Mġarr', '135'), -- Mġarr has 'Mġ'
    ('110', 'Attard', '135'),
    ('111', 'Qrendi', '135'),
    ('112', 'Naxxar', '135'),
    ('113', 'Gżira', '135'), -- Gżira has 'ż'
    ('114', 'Xagħra', '135'), -- Xagħra has 'Xagħ'
    ('115', 'Paola', '135'),
    ('116', 'Sannat', '135'),
    ('117', 'Dingli', '135'),
    ('118', 'Gudja', '135'),
    ('119', 'Qormi', '135'),
    ('120', 'Għargħur', '135'), -- Għargħur has 'Għ'
    ('121', 'Xewkija', '135'),
    ('122', 'Ta'' Xbiex', '135'), -- Fixed escaping of single quote
    ('123', 'Żabbar', '135'), -- Żabbar has 'Ż'
    ('124', 'Għaxaq', '135'), -- Għaxaq has 'Għ'
    ('125', 'Pembroke', '135'),
    ('126', 'Lija', '135'),
    ('127', 'Pietà', '135'), -- Pietà has 'à'
    ('128', 'Marsa', '135'),
    ('129', 'Fgura', '135'),
    ('130', 'Għajnsielem', '135'), -- Għajnsielem has 'Għ'
    ('131', 'Mtarfa', '135'),
    ('132', 'Munxar', '135'),
    ('133', 'Nadur', '135'),
    ('134', 'Fontana', '135'),
    ('135', 'Żejtun', '135'), -- Żejtun has 'Ż'
    ('136', 'Senglea', '135'),
    ('137', 'Marsaskala', '135'),
    ('138', 'Cospicua', '135'),
    ('139', 'St. Paul''s Bay', '135'), -- Fixed escaping of single quote
    ('140', 'Mosta', '135'),
    ('141', 'Mangystau Region', '112'),
    ('142', 'Kyzylorda Region', '112'),
    ('143', 'Almaty Region', '112'),
    ('144', 'North Kazakhstan Region', '112'),
    ('145', 'Akmola Region', '112'),
    ('146', 'Pavlodar Region', '112'),
    ('147', 'Jambyl Region', '112'),
    ('148', 'West Kazakhstan Province', '112'),
    ('149', 'Turkestan Region', '112'),
    ('150', 'Karaganda Region', '112'),
    ('151', 'Aktobe Region', '112'),
    ('152', 'Almaty', '112'),
    ('153', 'Atyrau Region', '112'),
    ('154', 'East Kazakhstan Region', '112'),
    ('155', 'Baikonur', '112'),
    ('156', 'Astana', '112'), -- Changed Nur-Sultan back to Astana (official name change 2022)
    ('157', 'Kostanay Region', '112'),
    ('158', 'Kakamega County', '113'),
    ('159', 'Kisii County', '113'),
    ('160', 'Central Province', '113'), -- Note: Provinces were replaced by Counties in 2013, keeping for historical data context
    ('161', 'Busia County', '113'),
    ('162', 'North Eastern Province', '113'),
    ('163', 'Embu County', '113'),
    ('164', 'Laikipia County', '113'),
    ('165', 'Nandi County', '113'), -- Changed District to County
    ('166', 'Lamu County', '113'),
    ('167', 'Kirinyaga County', '113'),
    ('168', 'Bungoma County', '113'),
    ('169', 'Uasin Gishu County', '113'), -- Changed District to County
    ('170', 'Isiolo County', '113'),
    ('171', 'Kisumu County', '113'),
    ('172', 'Coast Province', '113'),
    ('173', 'Kwale County', '113'),
    ('174', 'Kilifi County', '113'),
    ('175', 'Narok County', '113'),
    ('176', 'Taita-Taveta County', '113'), -- Changed en dash to hyphen
    ('177', 'Western Province', '113'),
    ('178', 'Murang''a County', '113'), -- Changed Muranga to Murang'a (correct spelling), fixed escaping
    ('179', 'Rift Valley Province', '113'),
    ('180', 'Nyeri County', '113'),
    ('181', 'Baringo County', '113'),
    ('182', 'Wajir County', '113'),
    ('183', 'Trans Nzoia County', '113'), -- Changed District to County, removed hyphen
    ('184', 'Machakos County', '113'),
    ('185', 'Tharaka-Nithi County', '113'), -- Corrected spelling Tharaka Nithi to Tharaka-Nithi
    ('186', 'Siaya County', '113'),
    ('187', 'Mandera County', '113'),
    ('188', 'Makueni County', '113'),
    ('189', 'Eastern Province', '113'),
    ('190', 'Migori County', '113'),
    ('191', 'Nairobi County', '113'), -- Changed Nairobi to Nairobi County
    ('192', 'Nyandarua County', '113'),
    ('193', 'Kericho County', '113'),
    ('194', 'Marsabit County', '113'),
    ('195', 'Homa Bay County', '113'),
    ('196', 'Garissa County', '113'),
    ('197', 'Kajiado County', '113'),
    ('198', 'Meru County', '113'),
    ('199', 'Kiambu County', '113'),
    ('200', 'Mombasa County', '113'),
    ('201', 'Elgeyo-Marakwet County', '113'),
    ('202', 'Vihiga County', '113'), -- Changed District to County
    ('203', 'Nakuru County', '113'), -- Changed District to County
    ('204', 'Nyanza Province', '113'),
    ('205', 'Tana River County', '113'),
    ('206', 'Turkana County', '113'),
    ('207', 'Samburu County', '113'),
    ('208', 'West Pokot County', '113'),
    ('209', 'Nyamira County', '113'), -- Changed District to County
    ('210', 'Bomet County', '113'),
    ('211', 'Kitui County', '113'),
    ('212', 'Bié Province', '7'), -- Bié has 'é'
    ('213', 'Huambo Province', '7'),
    ('214', 'Zaire Province', '7'),
    ('215', 'Cunene Province', '7'),
    ('216', 'Cuanza Sul Province', '7'), -- Added Province
    ('217', 'Cuanza Norte Province', '7'),
    ('218', 'Benguela Province', '7'),
    ('219', 'Moxico Province', '7'),
    ('220', 'Lunda Sul Province', '7'),
    ('221', 'Bengo Province', '7'),
    ('222', 'Luanda Province', '7'),
    ('223', 'Lunda Norte Province', '7'),
    ('224', 'Uíge Province', '7'), -- Uíge has 'í'
    ('225', 'Huíla Province', '7'), -- Huíla has 'í'
    ('226', 'Cuando Cubango Province', '7'),
    ('227', 'Malanje Province', '7'),
    ('228', 'Cabinda Province', '7'),
    ('229', 'Gasa District', '26'),
    ('230', 'Tsirang District', '26'),
    ('231', 'Wangdue Phodrang District', '26'),
    ('232', 'Haa District', '26'),
    ('233', 'Zhemgang District', '26'),
    ('234', 'Lhuntse District', '26'),
    ('235', 'Punakha District', '26'),
    ('236', 'Trashigang District', '26'),
    ('237', 'Paro District', '26'),
    ('238', 'Dagana District', '26'),
    ('239', 'Chukha District', '26'),
    ('240', 'Bumthang District', '26'),
    ('241', 'Thimphu District', '26'),
    ('242', 'Mongar District', '26'),
    ('243', 'Samdrup Jongkhar District', '26'),
    ('244', 'Pemagatshel District', '26'),
    ('245', 'Trongsa District', '26'),
    ('246', 'Samtse District', '26'),
    ('247', 'Sarpang District', '26'),
    ('248', 'Tombouctou Region', '134'),
    ('249', 'Ségou Region', '134'), -- Ségou has 'é'
    ('250', 'Koulikoro Region', '134'),
    ('251', 'Ménaka Region', '134'), -- Ménaka has 'é'
    ('252', 'Kayes Region', '134'),
    ('253', 'Bamako', '134'),
    ('254', 'Sikasso Region', '134'),
    ('255', 'Mopti Region', '134'),
    ('256', 'Taoudénit Region', '134'), -- Taoudénit has 'é'
    ('257', 'Kidal Region', '134'),
    ('258', 'Gao Region', '134'),
    ('259', 'Southern Province', '183'),
    ('260', 'Western Province', '183'),
    ('261', 'Eastern Province', '183'),
    ('262', 'Kigali City', '183'), -- Changed Kigali district to Kigali City (official status)
    ('263', 'Northern Province', '183'),
    ('264', 'Belize District', '23'),
    ('265', 'Stann Creek District', '23'),
    ('266', 'Corozal District', '23'),
    ('267', 'Toledo District', '23'),
    ('268', 'Orange Walk District', '23'),
    ('269', 'Cayo District', '23'),
    ('270', 'Príncipe Province', '193'), -- Príncipe has 'í'
    ('271', 'São Tomé Province', '193'), -- São Tomé has 'ã' and 'é'
    ('272', 'Havana Province', '56'), -- La Habana
    ('273', 'Santiago de Cuba Province', '56'),
    ('274', 'Sancti Spíritus Province', '56'), -- Spíritus has 'í'
    ('275', 'Granma Province', '56'),
    ('276', 'Mayabeque Province', '56'),
    ('277', 'Pinar del Río Province', '56'), -- Río has 'í'
    ('278', 'Isla de la Juventud', '56'),
    ('279', 'Holguín Province', '56'), -- Holguín has 'í'
    ('280', 'Villa Clara Province', '56'),
    ('281', 'Las Tunas Province', '56'),
    ('282', 'Ciego de Ávila Province', '56'), -- Ávila has 'Á'
    ('283', 'Artemisa Province', '56'),
    ('284', 'Matanzas Province', '56'),
    ('285', 'Guantánamo Province', '56'), -- Guantánamo has 'á'
    ('286', 'Camagüey Province', '56'), -- Camagüey has 'ü'
    ('287', 'Cienfuegos Province', '56'),
    ('288', 'Jigawa State', '161'),
    ('289', 'Enugu State', '161'),
    ('290', 'Kebbi State', '161'),
    ('291', 'Benue State', '161'),
    ('292', 'Sokoto State', '161'),
    ('293', 'Federal Capital Territory', '161'),
    ('294', 'Kaduna State', '161'),
    ('295', 'Kwara State', '161'),
    ('296', 'Oyo State', '161'),
    ('297', 'Yobe State', '161'),
    ('298', 'Kogi State', '161'),
    ('299', 'Zamfara State', '161'),
    ('300', 'Kano State', '161'),
    ('301', 'Nasarawa State', '161'),
    ('302', 'Plateau State', '161'),
    ('303', 'Abia State', '161'),
    ('304', 'Akwa Ibom State', '161'),
    ('305', 'Bayelsa State', '161'),
    ('306', 'Lagos State', '161'), -- Changed Lagos to Lagos State
    ('307', 'Borno State', '161'),
    ('308', 'Imo State', '161'),
    ('309', 'Ekiti State', '161'),
    ('310', 'Gombe State', '161'),
    ('311', 'Ebonyi State', '161'),
    ('312', 'Bauchi State', '161'),
    ('313', 'Katsina State', '161'),
    ('314', 'Cross River State', '161'),
    ('315', 'Anambra State', '161'),
    ('316', 'Delta State', '161'),
    ('317', 'Niger State', '161'),
    ('318', 'Edo State', '161'),
    ('319', 'Taraba State', '161'),
    ('320', 'Adamawa State', '161'),
    ('321', 'Ondo State', '161'),
    ('322', 'Osun State', '161'),
    ('323', 'Ogun State', '161'),
    ('324', 'Rukungiri District', '229'),
    ('325', 'Kyankwanzi District', '229'),
    ('326', 'Kabarole District', '229'),
    ('327', 'Mpigi District', '229'),
    ('328', 'Apac District', '229'),
    ('329', 'Abim District', '229'),
    ('330', 'Yumbe District', '229'),
    ('331', 'Rukiga District', '229'),
    ('332', 'Northern Region', '229'),
    ('333', 'Serere District', '229'),
    ('334', 'Kamuli District', '229'),
    ('335', 'Amuru District', '229'),
    ('336', 'Kaberamaido District', '229'),
    ('337', 'Namutumba District', '229'),
    ('338', 'Kibuku District', '229'),
    ('339', 'Ibanda District', '229'),
    ('340', 'Iganga District', '229'),
    ('341', 'Dokolo District', '229'),
    ('342', 'Lira District', '229'),
    ('343', 'Bukedea District', '229'),
    ('344', 'Alebtong District', '229'),
    ('345', 'Koboko District', '229'),
    ('346', 'Kiryandongo District', '229'),
    ('347', 'Kiboga District', '229'),
    ('348', 'Kitgum District', '229'),
    ('349', 'Bududa District', '229'),
    ('350', 'Mbale District', '229'),
    ('351', 'Namayingo District', '229'),
    ('352', 'Amuria District', '229'),
    ('353', 'Amudat District', '229'),
    ('354', 'Masindi District', '229'),
    ('355', 'Kiruhura District', '229'),
    ('356', 'Masaka District', '229'),
    ('357', 'Pakwach District', '229'),
    ('358', 'Rubanda District', '229'),
    ('359', 'Tororo District', '229'),
    ('360', 'Kamwenge District', '229'),
    ('361', 'Adjumani District', '229'),
    ('362', 'Wakiso District', '229'),
    ('363', 'Moyo District', '229'),
    ('364', 'Mityana District', '229'),
    ('365', 'Butaleja District', '229'),
    ('366', 'Gomba District', '229'),
    ('367', 'Jinja District', '229'),
    ('368', 'Kayunga District', '229'),
    ('369', 'Kween District', '229'),
    ('370', 'Western Region', '229'),
    ('371', 'Mubende District', '229'),
    ('372', 'Eastern Region', '229'),
    ('373', 'Kanungu District', '229'),
    ('374', 'Omoro District', '229'),
    ('375', 'Bukomansimbi District', '229'),
    ('376', 'Lyantonde District', '229'),
    ('377', 'Buikwe District', '229'),
    ('378', 'Nwoya District', '229'),
    ('379', 'Zombo District', '229'),
    ('380', 'Buyende District', '229'),
    ('381', 'Bunyangabu District', '229'),
    ('382', 'Kampala District', '229'),
    ('383', 'Isingiro District', '229'),
    ('384', 'Butambala District', '229'),
    ('385', 'Bukwo District', '229'),
    ('386', 'Bushenyi District', '229'),
    ('387', 'Bugiri District', '229'),
    ('388', 'Butebo District', '229'),
    ('389', 'Buliisa District', '229'),
    ('390', 'Otuke District', '229'),
    ('391', 'Buhweju District', '229'),
    ('392', 'Agago District', '229'),
    ('393', 'Nakapiripirit District', '229'),
    ('394', 'Kalungu District', '229'),
    ('395', 'Moroto District', '229'),
    ('396', 'Central Region', '229'),
    ('397', 'Oyam District', '229'),
    ('398', 'Kaliro District', '229'),
    ('399', 'Kakumiro District', '229'),
    ('400', 'Namisindwa District', '229'),
    ('401', 'Kole District', '229'),
    ('402', 'Kyenjojo District', '229'),
    ('403', 'Kagadi District', '229'),
    ('404', 'Ntungamo District', '229'),
    ('405', 'Kalangala District', '229'),
    ('406', 'Nakasongola District', '229'),
    ('407', 'Sheema District', '229'),
    ('408', 'Pader District', '229'),
    ('409', 'Kisoro District', '229'),
    ('410', 'Mukono District', '229'),
    ('411', 'Lamwo District', '229'),
    ('412', 'Pallisa District', '229'),
    ('413', 'Gulu District', '229'),
    ('414', 'Buvuma District', '229'),
    ('415', 'Mbarara District', '229'),
    ('416', 'Amolatar District', '229'),
    ('417', 'Lwengo District', '229'),
    ('418', 'Mayuge District', '229'),
    ('419', 'Bundibugyo District', '229'),
    ('420', 'Katakwi District', '229'),
    ('421', 'Maracha District', '229'),
    ('422', 'Ntoroko District', '229'),
    ('423', 'Nakaseke District', '229'),
    ('424', 'Ngora District', '229'),
    ('425', 'Kumi District', '229'),
    ('426', 'Kabale District', '229'),
    ('427', 'Sembabule District', '229'),
    ('428', 'Bulambuli District', '229'),
    ('429', 'Sironko District', '229'),
    ('430', 'Napak District', '229'),
    ('431', 'Busia District', '229'),
    ('432', 'Kapchorwa District', '229'),
    ('433', 'Luwero District', '229'),
    ('434', 'Kaabong District', '229'),
    ('435', 'Mitooma District', '229'),
    ('436', 'Kibaale District', '229'),
    ('437', 'Kyegegwa District', '229'),
    ('438', 'Manafwa District', '229'),
    ('439', 'Rakai District', '229'),
    ('440', 'Kasese District', '229'),
    ('441', 'Budaka District', '229'),
    ('442', 'Rubirizi District', '229'),
    ('443', 'Kotido District', '229'),
    ('444', 'Soroti District', '229'),
    ('445', 'Luuka District', '229'),
    ('446', 'Nebbi District', '229'),
    ('447', 'Arua District', '229'),
    ('448', 'Kyotera District', '229'),
    ('449', 'Schellenberg', '125'),
    ('450', 'Schaan', '125'),
    ('451', 'Eschen', '125'),
    ('452', 'Vaduz', '125'),
    ('453', 'Ruggell', '125'),
    ('454', 'Planken', '125'),
    ('455', 'Mauren', '125'),
    ('456', 'Triesenberg', '125'),
    ('457', 'Gamprin', '125'),
    ('458', 'Balzers', '125'),
    ('459', 'Triesen', '125'),
    ('460', 'Brčko District', '28'), -- Brčko has 'č'
    ('461', 'Tuzla Canton', '28'),
    ('462', 'Central Bosnia Canton', '28'),
    ('463', 'Herzegovina-Neretva Canton', '28'),
    ('464', 'Posavina Canton', '28'),
    ('465', 'Una-Sana Canton', '28'),
    ('466', 'Sarajevo Canton', '28'),
    (
        '467',
        'Federation of Bosnia and Herzegovina',
        '28'
    ),
    ('468', 'Zenica-Doboj Canton', '28'),
    ('469', 'West Herzegovina Canton', '28'),
    ('470', 'Republika Srpska', '28'),
    ('471', 'Canton 10', '28'), -- (Hercegbosna Canton)
    ('472', 'Bosnian Podrinje Canton Goražde', '28'), -- Added Goražde (official name 'ž')
    ('473', 'Dakar Region', '195'), -- Changed Dakar to Dakar Region
    ('474', 'Kolda Region', '195'), -- Changed Kolda to Kolda Region
    ('475', 'Kaffrine Region', '195'), -- Changed Kaffrine to Kaffrine Region
    ('476', 'Matam Region', '195'), -- Changed Matam to Matam Region
    ('477', 'Saint-Louis Region', '195'), -- Changed Saint-Louis to Saint-Louis Region
    ('478', 'Ziguinchor Region', '195'), -- Changed Ziguinchor to Ziguinchor Region
    ('479', 'Fatick Region', '195'), -- Changed Fatick to Fatick Region
    ('480', 'Diourbel Region', '195'),
    ('481', 'Kédougou Region', '195'), -- Changed Kédougou to Kédougou Region ('é')
    ('482', 'Sédhiou Region', '195'), -- Changed Sédhiou to Sédhiou Region ('é')
    ('483', 'Kaolack Region', '195'), -- Changed Kaolack to Kaolack Region
    ('484', 'Thiès Region', '195'), -- Thiès has 'è'
    ('485', 'Louga Region', '195'), -- Changed Louga to Louga Region
    ('486', 'Tambacounda Region', '195'),
    ('487', 'Encamp', '6'),
    ('488', 'Andorra la Vella', '6'),
    ('489', 'Canillo', '6'),
    ('490', 'Sant Julià de Lòria', '6'), -- Julià has 'à', Lòria has 'ò'
    ('491', 'Ordino', '6'),
    ('492', 'Escaldes-Engordany', '6'),
    ('493', 'La Massana', '6'),
    ('494', 'Mont Buxton', '197'),
    ('495', 'La Digue', '197'),
    ('496', 'Saint Louis', '197'),
    ('497', 'Baie Lazare', '197'),
    ('498', 'Mont Fleuri', '197'),
    ('499', 'Les Mamelles', '197'),
    ('500', 'Grand''Anse Mahé', '197'), -- Fixed escaping of single quote, Mahé has 'é'
    ('501', 'Roche Caïman', '197'), -- Caïman has 'ï'
    ('502', 'Anse Royale', '197'),
    ('503', 'Glacis', '197'),
    ('504', 'Grand''Anse Praslin', '197'), -- Fixed escaping of single quote
    ('505', 'Bel Ombre', '197'),
    ('506', 'Anse-aux-Pins', '197'),
    ('507', 'Port Glaud', '197'),
    ('508', 'Au Cap', '197'),
    ('509', 'Takamaka', '197'),
    ('510', 'Pointe La Rue', '197'),
    ('511', 'Plaisance', '197'),
    ('512', 'Beau Vallon', '197'),
    ('513', 'Anse Boileau', '197'),
    ('514', 'Baie Sainte Anne', '197'), -- Sainte has 'î'
    ('515', 'Bel Air', '197'),
    ('516', 'La Rivière Anglaise', '197'), -- Rivière has 'è'
    ('517', 'Cascade', '197'),
    ('518', 'Shaki City', '16'), -- Changed Shaki to Shaki City (matches Mingachevir etc.)
    ('519', 'Tartar District', '16'), -- Tərtər
    ('520', 'Shirvan City', '16'), -- Changed Shirvan to Shirvan City
    ('521', 'Qazakh District', '16'),
    ('522', 'Sadarak District', '16'), -- Sədərək
    ('523', 'Yevlakh District', '16'),
    ('524', 'Khojali District', '16'), -- Xocalı
    ('525', 'Kalbajar District', '16'), -- Kəlbəcər
    ('526', 'Qakh District', '16'), -- Qax
    ('527', 'Fizuli District', '16'), -- Füzuli
    ('528', 'Astara District', '16'),
    ('529', 'Shamakhi District', '16'), -- Şamaxı
    ('530', 'Neftchala District', '16'), -- Neftçala
    ('531', 'Goychay District', '16'), -- Göyçay, changed Goychay to Goychay District
    ('532', 'Bilasuvar District', '16'),
    ('533', 'Tovuz District', '16'),
    ('534', 'Ordubad District', '16'),
    ('535', 'Sharur District', '16'), -- Şərur
    ('536', 'Samukh District', '16'),
    ('537', 'Khizi District', '16'), -- Xızı
    ('538', 'Yevlakh City', '16'), -- Changed Yevlakh to Yevlakh City
    ('539', 'Ujar District', '16'),
    ('540', 'Absheron District', '16'), -- Abşeron
    ('541', 'Lachin District', '16'), -- Laçın
    ('542', 'Qabala District', '16'), -- Qəbələ
    ('543', 'Agstafa District', '16'), -- Ağstafa
    ('544', 'Imishli District', '16'), -- İmişli
    ('545', 'Salyan District', '16'),
    ('546', 'Lerik District', '16'),
    ('547', 'Agsu District', '16'), -- Ağsu
    ('548', 'Qubadli District', '16'),
    ('549', 'Kurdamir District', '16'), -- Kürdəmir
    ('550', 'Yardymli District', '16'), -- Yardımlı
    ('551', 'Goranboy District', '16'),
    ('552', 'Baku', '16'), -- Bakı
    ('553', 'Agdash District', '16'), -- Ağdaş
    ('554', 'Beylagan District', '16'), -- Beyləqan
    ('555', 'Masally District', '16'), -- Masallı
    ('556', 'Oghuz District', '16'), -- Oğuz
    ('557', 'Saatly District', '16'), -- Saatlı
    ('558', 'Lankaran District', '16'), -- Lənkəran
    ('559', 'Agdam District', '16'), -- Ağdam
    ('560', 'Balakan District', '16'), -- Balakən
    ('561', 'Dashkasan District', '16'), -- Daşkəsən
    ('562', 'Nakhchivan Autonomous Republic', '16'), -- Naxçıvan Muxtar Respublikası
    ('563', 'Quba District', '16'),
    ('564', 'Ismailli District', '16'), -- İsmayıllı
    ('565', 'Sabirabad District', '16'),
    ('566', 'Zaqatala District', '16'),
    ('567', 'Kangarli District', '16'), -- Kəngərli
    ('568', 'Martuni', '16'), -- Khojavend (Xocavənd) District
    ('569', 'Barda District', '16'), -- Bərdə
    ('570', 'Jabrayil District', '16'), -- Cəbrayıl
    ('571', 'Hajigabul District', '16'), -- Hacıqabul
    ('572', 'Julfa District', '16'), -- Culfa
    ('573', 'Gobustan District', '16'), -- Qobustan
    ('574', 'Goygol District', '16'), -- Göygöl
    ('575', 'Babek District', '16'), -- Babək
    ('576', 'Zardab District', '16'),
    ('577', 'Aghjabadi District', '16'), -- Ağcabədi
    ('578', 'Jalilabad District', '16'), -- Cəlilabad
    ('579', 'Shahbuz District', '16'), -- Şahbuz
    ('580', 'Mingachevir City', '16'), -- Mingəçevir, changed Mingachevir to Mingachevir City
    ('581', 'Zangilan District', '16'), -- Zəngilan
    ('582', 'Sumqayit City', '16'), -- Sumqayıt, changed Sumqayit to Sumqayit City
    ('583', 'Shamkir District', '16'), -- Şəmkir
    ('584', 'Siazan District', '16'), -- Siyəzən
    ('585', 'Ganja City', '16'), -- Gəncə, changed Ganja to Ganja City
    ('586', 'Shaki District', '16'), -- Şəki
    ('587', 'Lankaran City', '16'), -- Lənkəran, changed Lankaran to Lankaran City
    ('588', 'Qusar District', '16'),
    ('589', 'Gadabay District', '16'), -- Gədəbəy, changed Gədəbəy to Gadabay District
    ('590', 'Khachmaz District', '16'), -- Xaçmaz
    ('591', 'Shabran District', '16'), -- Şabran
    ('592', 'Shusha District', '16'), -- Şuşa
    ('593', 'Skrapar District', '3'), -- Note: Districts abolished in 2000, replaced by Counties/Municipalities. Keeping for historical context.
    ('594', 'Kavajë District', '3'), -- Kavajë has 'ë'
    ('595', 'Lezhë District', '3'), -- Lezhë has 'ë'
    ('596', 'Librazhd District', '3'),
    ('597', 'Korçë District', '3'), -- Korçë has 'ç', 'ë'
    ('598', 'Elbasan County', '3'),
    ('599', 'Lushnjë District', '3'), -- Lushnjë has 'ë'
    ('600', 'Has District', '3'),
    ('601', 'Kukës County', '3'), -- Kukës has 'ë'
    ('602', 'Malësi e Madhe District', '3'), -- Malësi has 'ë'
    ('603', 'Berat County', '3'),
    ('604', 'Gjirokastër County', '3'), -- Gjirokastër has 'ë'
    ('605', 'Dibër District', '3'), -- Dibër has 'ë'
    ('606', 'Pogradec District', '3'),
    ('607', 'Bulqizë District', '3'), -- Bulqizë has 'ë'
    ('608', 'Devoll District', '3'),
    ('609', 'Lezhë County', '3'), -- Lezhë has 'ë'
    ('610', 'Dibër County', '3'), -- Dibër has 'ë'
    ('611', 'Shkodër County', '3'), -- Shkodër has 'ë'
    ('612', 'Kuçovë District', '3'), -- Kuçovë has 'ç', 'ë'
    ('613', 'Vlorë District', '3'), -- Vlorë has 'ë'
    ('614', 'Krujë District', '3'), -- Krujë has 'ë'
    ('615', 'Tirana County', '3'),
    ('616', 'Tepelenë District', '3'), -- Tepelenë has 'ë'
    ('617', 'Gramsh District', '3'),
    ('618', 'Delvinë District', '3'), -- Delvinë has 'ë'
    ('619', 'Peqin District', '3'),
    ('620', 'Pukë District', '3'), -- Pukë has 'ë'
    ('621', 'Gjirokastër District', '3'), -- Gjirokastër has 'ë'
    ('622', 'Kurbin District', '3'),
    ('623', 'Kukës District', '3'), -- Kukës has 'ë'
    ('624', 'Sarandë District', '3'), -- Sarandë has 'ë'
    ('625', 'Përmet District', '3'), -- Përmet has 'ë'
    ('626', 'Shkodër District', '3'), -- Shkodër has 'ë'
    ('627', 'Fier District', '3'),
    ('628', 'Kolonjë District', '3'), -- Kolonjë has 'ë'
    ('629', 'Berat District', '3'),
    ('630', 'Korçë County', '3'), -- Korçë has 'ç', 'ë'
    ('631', 'Fier County', '3'),
    ('632', 'Durrës County', '3'), -- Durrës has 'ë'
    ('633', 'Tirana District', '3'),
    ('634', 'Vlorë County', '3'), -- Vlorë has 'ë'
    ('635', 'Mat District', '3'),
    ('636', 'Tropojë District', '3'), -- Tropojë has 'ë'
    ('637', 'Mallakastër District', '3'), -- Mallakastër has 'ë'
    ('638', 'Mirditë District', '3'), -- Mirditë has 'ë'
    ('639', 'Durrës District', '3'), -- Durrës has 'ë'
    ('640', 'Sveti Nikole Municipality', '129'), -- Note: Name changed to North Macedonia in 2019. Keeping Macedonia for data consistency.
    ('641', 'Kratovo Municipality', '129'),
    ('642', 'Zajas Municipality', '129'), -- Merged into Kičevo
    ('643', 'Staro Nagoričane Municipality', '129'), -- Nagoričane has 'č'
    ('644', 'Češinovo-Obleševo Municipality', '129'), -- Češinovo has 'Č', 'š'
    ('645', 'Debarca Municipality', '129'),
    ('646', 'Probištip Municipality', '129'), -- Probištip has 'š'
    ('647', 'Krivogaštani Municipality', '129'), -- Krivogaštani has 'š'
    ('648', 'Gevgelija Municipality', '129'),
    ('649', 'Bogdanci Municipality', '129'),
    ('650', 'Vraneštica Municipality', '129'), -- Vraneštica has 'š', Merged into Kičevo
    ('651', 'Veles Municipality', '129'),
    ('652', 'Bosilovo Municipality', '129'),
    ('653', 'Mogila Municipality', '129'),
    ('654', 'Tearce Municipality', '129'),
    ('655', 'Demir Kapija Municipality', '129'),
    ('656', 'Aračinovo Municipality', '129'), -- Aračinovo has 'č'
    ('657', 'Drugovo Municipality', '129'), -- Merged into Kičevo
    ('658', 'Vasilevo Municipality', '129'),
    ('659', 'Lipkovo Municipality', '129'),
    ('660', 'Brvenica Municipality', '129'),
    ('661', 'Štip Municipality', '129'), -- Štip has 'Š'
    ('662', 'Vevčani Municipality', '129'), -- Vevčani has 'č'
    ('663', 'Tetovo Municipality', '129'),
    ('664', 'Negotino Municipality', '129'),
    ('665', 'Konče Municipality', '129'), -- Konče has 'č'
    ('666', 'Prilep Municipality', '129'),
    ('667', 'Saraj Municipality', '129'),
    ('668', 'Želino Municipality', '129'), -- Želino has 'Ž'
    ('669', 'Mavrovo and Rostuša Municipality', '129'), -- Rostuša has 'š'
    ('670', 'Plasnica Municipality', '129'),
    ('671', 'Valandovo Municipality', '129'),
    ('672', 'Vinica Municipality', '129'),
    ('673', 'Zrnovci Municipality', '129'),
    ('674', 'Karbinci Municipality', '129'), -- Added Municipality
    ('675', 'Dolneni Municipality', '129'),
    ('676', 'Čaška Municipality', '129'), -- Čaška has 'Č', 'š'
    ('677', 'Kriva Palanka Municipality', '129'),
    ('678', 'Jegunovce Municipality', '129'),
    ('679', 'Bitola Municipality', '129'),
    ('680', 'Šuto Orizari Municipality', '129'), -- Šuto has 'Š'
    ('681', 'Karpoš Municipality', '129'), -- Karpoš has 'š'
    ('682', 'Oslomej Municipality', '129'), -- Merged into Kičevo
    ('683', 'Kumanovo Municipality', '129'),
    ('684', 'City of Skopje', '129'), -- Changed Greater Skopje to City of Skopje (official unit)
    ('685', 'Pehčevo Municipality', '129'), -- Pehčevo has 'č'
    ('686', 'Kisela Voda Municipality', '129'),
    ('687', 'Demir Hisar Municipality', '129'),
    ('688', 'Kičevo Municipality', '129'), -- Kičevo has 'č'
    ('689', 'Vrapčište Municipality', '129'), -- Vrapčište has 'č', 'š'
    ('690', 'Ilinden Municipality', '129'),
    ('691', 'Rosoman Municipality', '129'),
    ('692', 'Makedonski Brod Municipality', '129'),
    ('693', 'Gostivar Municipality', '129'),
    ('694', 'Butel Municipality', '129'),
    ('695', 'Delčevo Municipality', '129'), -- Delčevo has 'č'
    ('696', 'Novaci Municipality', '129'),
    ('697', 'Dojran Municipality', '129'),
    ('698', 'Petrovec Municipality', '129'),
    ('699', 'Ohrid Municipality', '129'),
    ('700', 'Struga Municipality', '129'),
    ('701', 'Makedonska Kamenica Municipality', '129'),
    ('702', 'Centar Municipality', '129'),
    ('703', 'Aerodrom Municipality', '129'),
    ('704', 'Čair Municipality', '129'), -- Čair has 'Č'
    ('705', 'Lozovo Municipality', '129'),
    ('706', 'Zelenikovo Municipality', '129'),
    ('707', 'Gazi Baba Municipality', '129'),
    ('708', 'Gradsko Municipality', '129'),
    ('709', 'Radoviš Municipality', '129'), -- Radoviš has 'š'
    ('710', 'Strumica Municipality', '129'),
    ('711', 'Studeničani Municipality', '129'), -- Studeničani has 'č'
    ('712', 'Resen Municipality', '129'),
    ('713', 'Kavadarci Municipality', '129'),
    ('714', 'Kruševo Municipality', '129'), -- Kruševo has 'š'
    ('715', 'Čučer-Sandevo Municipality', '129'), -- Čučer has 'Č', 'č'
    ('716', 'Berovo Municipality', '129'),
    ('717', 'Rankovce Municipality', '129'),
    ('718', 'Novo Selo Municipality', '129'),
    ('719', 'Sopište Municipality', '129'), -- Sopište has 'š'
    ('720', 'Centar Župa Municipality', '129'), -- Župa has 'Ž'
    ('721', 'Bogovinje Municipality', '129'),
    ('722', 'Gjorče Petrov Municipality', '129'), -- Gjorče has 'č'
    ('723', 'Kočani Municipality', '129'), -- Kočani has 'č'
    ('724', 'Požega-Slavonia County', '55'), -- Požega has 'ž'
    ('725', 'Split-Dalmatia County', '55'),
    ('726', 'Međimurje County', '55'), -- Međimurje has 'đ'
    ('727', 'Zadar County', '55'),
    ('728', 'Dubrovnik-Neretva County', '55'),
    ('729', 'Krapina-Zagorje County', '55'),
    ('730', 'Šibenik-Knin County', '55'), -- Šibenik has 'Š'
    ('731', 'Lika-Senj County', '55'),
    ('732', 'Virovitica-Podravina County', '55'),
    ('733', 'Sisak-Moslavina County', '55'),
    ('734', 'Bjelovar-Bilogora County', '55'),
    ('735', 'Primorje-Gorski Kotar County', '55'),
    ('736', 'Zagreb County', '55'),
    ('737', 'Brod-Posavina County', '55'),
    ('738', 'City of Zagreb', '55'), -- Changed Zagreb to City of Zagreb (official status)
    ('739', 'Varaždin County', '55'), -- Varaždin has 'ž'
    ('740', 'Osijek-Baranja County', '55'),
    ('741', 'Vukovar-Syrmia County', '55'),
    ('742', 'Koprivnica-Križevci County', '55'), -- Križevci has 'ž'
    ('743', 'Istria County', '55'),
    ('744', 'Kyrenia District', '57'), -- (Girne)
    ('745', 'Nicosia District', '57'), -- (Lefkoşa)
    ('746', 'Paphos District', '57'), -- (Pafos)
    ('747', 'Larnaca District', '57'), -- (Larnaka)
    ('748', 'Limassol District', '57'), -- (Lemesos)
    ('749', 'Famagusta District', '57'), -- (Gazimağusa/Ammochostos)
    ('750', 'Rangpur Division', '19'),
    ('751', 'Cox''s Bazar District', '19'), -- Fixed escaping of single quote
    ('752', 'Bandarban District', '19'),
    ('753', 'Rajshahi Division', '19'),
    ('754', 'Pabna District', '19'),
    ('755', 'Sherpur District', '19'),
    ('756', 'Bhola District', '19'),
    ('757', 'Jashore District', '19'), -- Changed Jessore to Jashore (official spelling change)
    ('758', 'Mymensingh Division', '19'),
    ('759', 'Rangpur District', '19'),
    ('760', 'Dhaka Division', '19'),
    ('761', 'Chapai Nawabganj District', '19'),
    ('762', 'Faridpur District', '19'),
    ('763', 'Cumilla District', '19'), -- Changed Comilla to Cumilla (official spelling change)
    ('764', 'Netrokona District', '19'),
    ('765', 'Sylhet Division', '19'),
    ('766', 'Mymensingh District', '19'),
    ('767', 'Sylhet District', '19'),
    ('768', 'Chandpur District', '19'),
    ('769', 'Narail District', '19'),
    ('770', 'Narayanganj District', '19'),
    ('771', 'Dhaka District', '19'),
    ('772', 'Nilphamari District', '19'),
    ('773', 'Rajbari District', '19'),
    ('774', 'Kushtia District', '19'),
    ('775', 'Khulna Division', '19'),
    ('776', 'Meherpur District', '19'),
    ('777', 'Patuakhali District', '19'),
    ('778', 'Jhalokati District', '19'),
    ('779', 'Kishoreganj District', '19'),
    ('780', 'Lalmonirhat District', '19'),
    ('781', 'Sirajganj District', '19'),
    ('782', 'Tangail District', '19'),
    ('783', 'Dinajpur District', '19'),
    ('784', 'Barguna District', '19'),
    ('785', 'Chattogram District', '19'), -- Changed Chittagong to Chattogram (official spelling change)
    ('786', 'Khagrachari District', '19'),
    ('787', 'Natore District', '19'),
    ('788', 'Chuadanga District', '19'),
    ('789', 'Jhenaidah District', '19'),
    ('790', 'Munshiganj District', '19'),
    ('791', 'Pirojpur District', '19'),
    ('792', 'Gopalganj District', '19'),
    ('793', 'Kurigram District', '19'),
    ('794', 'Moulvibazar District', '19'),
    ('795', 'Gaibandha District', '19'),
    ('796', 'Bagerhat District', '19'),
    ('797', 'Bogura District', '19'), -- Changed Bogra to Bogura (official spelling change)
    ('798', 'Gazipur District', '19'),
    ('799', 'Satkhira District', '19'),
    ('800', 'Panchagarh District', '19'),
    ('801', 'Shariatpur District', '19'),
    ('802', 'Barishal District', '19'), -- Corrected spelling Bahadia -> Barishal District, fixed ID conflict (was 818) / Changed Barisal to Barishal
    ('803', 'Chattogram Division', '19'), -- Changed Chittagong to Chattogram (official spelling change)
    ('804', 'Thakurgaon District', '19'),
    ('805', 'Habiganj District', '19'),
    ('806', 'Joypurhat District', '19'),
    ('807', 'Barishal Division', '19'), -- Changed Barisal to Barishal (official spelling change)
    ('808', 'Jamalpur District', '19'),
    ('809', 'Rangamati Hill District', '19'),
    ('810', 'Brahmanbaria District', '19'),
    ('811', 'Khulna District', '19'),
    ('812', 'Sunamganj District', '19'),
    ('813', 'Rajshahi District', '19'),
    ('814', 'Naogaon District', '19'),
    ('815', 'Noakhali District', '19'),
    ('816', 'Feni District', '19'),
    ('817', 'Madaripur District', '19'),
    ('818', 'Barishal District', '19'), -- Changed Barisal to Barishal (official spelling change). Note: ID 802 also corrected to Barishal. Keep this entry? Check if distinct. Assuming distinct subdivision, keeping both with updated spelling.
    ('819', 'Lakshmipur District', '19'),
    ('820', 'Okayama Prefecture', '109'),
    ('821', 'Chiba Prefecture', '109'),
    ('822', 'Ōita Prefecture', '109'), -- Ōita has 'Ō'
    ('823', 'Tokyo Metropolis', '109'), -- Changed Tokyo to Tokyo Metropolis (official designation)
    ('824', 'Nara Prefecture', '109'),
    ('825', 'Shizuoka Prefecture', '109'),
    ('826', 'Shimane Prefecture', '109'),
    ('827', 'Aichi Prefecture', '109'),
    ('828', 'Hiroshima Prefecture', '109'),
    ('829', 'Akita Prefecture', '109'),
    ('830', 'Ishikawa Prefecture', '109'),
    ('831', 'Hyōgo Prefecture', '109'), -- Hyōgo has 'ō'
    ('832', 'Hokkaidō', '109'), -- Changed Hokkaidō Prefecture to Hokkaidō (official designation)
    ('833', 'Mie Prefecture', '109'),
    ('834', 'Kyōto Prefecture', '109'), -- Kyōto has 'ō'
    ('835', 'Yamaguchi Prefecture', '109'),
    ('836', 'Tokushima Prefecture', '109'),
    ('837', 'Yamagata Prefecture', '109'),
    ('838', 'Toyama Prefecture', '109'),
    ('839', 'Aomori Prefecture', '109'),
    ('840', 'Kagoshima Prefecture', '109'),
    ('841', 'Niigata Prefecture', '109'),
    ('842', 'Kanagawa Prefecture', '109'),
    ('843', 'Nagano Prefecture', '109'),
    ('844', 'Wakayama Prefecture', '109'),
    ('845', 'Shiga Prefecture', '109'),
    ('846', 'Kumamoto Prefecture', '109'),
    ('847', 'Fukushima Prefecture', '109'),
    ('848', 'Fukui Prefecture', '109'),
    ('849', 'Nagasaki Prefecture', '109'),
    ('850', 'Tottori Prefecture', '109'),
    ('851', 'Ibaraki Prefecture', '109'),
    ('852', 'Yamanashi Prefecture', '109'),
    ('853', 'Okinawa Prefecture', '109'),
    ('854', 'Tochigi Prefecture', '109'),
    ('855', 'Miyazaki Prefecture', '109'),
    ('856', 'Iwate Prefecture', '109'),
    ('857', 'Miyagi Prefecture', '109'),
    ('858', 'Gifu Prefecture', '109'),
    ('859', 'Ōsaka Prefecture', '109'), -- Ōsaka has 'Ō'
    ('860', 'Saitama Prefecture', '109'),
    ('861', 'Fukuoka Prefecture', '109'),
    ('862', 'Gunma Prefecture', '109'),
    ('863', 'Saga Prefecture', '109'),
    ('864', 'Kagawa Prefecture', '109'),
    ('865', 'Ehime Prefecture', '109'),
    ('866', 'Ontario', '39'),
    ('867', 'Manitoba', '39'),
    ('868', 'New Brunswick', '39'),
    ('869', 'Yukon', '39'),
    ('870', 'Saskatchewan', '39'),
    ('871', 'Prince Edward Island', '39'),
    ('872', 'Alberta', '39'),
    ('873', 'Quebec', '39'),
    ('874', 'Nova Scotia', '39'),
    ('875', 'British Columbia', '39'),
    ('876', 'Nunavut', '39'),
    ('877', 'Newfoundland and Labrador', '39'),
    ('878', 'Northwest Territories', '39'),
    ('879', 'White Nile', '209'),
    ('880', 'Red Sea', '209'),
    ('881', 'Khartoum', '209'),
    ('882', 'Sennar', '209'),
    ('883', 'South Kordofan', '209'),
    ('884', 'Kassala', '209'),
    ('885', 'Al Jazirah', '209'),
    ('886', 'Al Qadarif', '209'),
    ('887', 'Blue Nile', '209'),
    ('888', 'West Darfur', '209'),
    ('889', 'West Kordofan', '209'),
    ('890', 'North Darfur', '209'),
    ('891', 'River Nile', '209'),
    ('892', 'East Darfur', '209'),
    ('893', 'North Kordofan', '209'),
    ('894', 'South Darfur', '209'),
    ('895', 'Northern', '209'),
    ('896', 'Central Darfur', '209'),
    ('897', 'Khelvachauri Municipality', '81'),
    ('898', 'Senaki Municipality', '81'),
    ('899', 'Tbilisi', '81'),
    ('900', 'Adjara', '81'),
    ('901', 'Autonomous Republic of Abkhazia', '81'), -- Note: Disputed territory
    ('902', 'Mtskheta-Mtianeti', '81'),
    ('903', 'Shida Kartli', '81'), -- Note: Includes parts of disputed South Ossetia
    ('904', 'Kvemo Kartli', '81'),
    ('905', 'Imereti', '81'),
    ('906', 'Samtskhe-Javakheti', '81'),
    ('907', 'Guria', '81'),
    ('908', 'Samegrelo-Zemo Svaneti', '81'),
    ('909', 'Racha-Lechkhumi and Kvemo Svaneti', '81'),
    ('910', 'Kakheti', '81'),
    ('911', 'Northern Province', '198'),
    ('912', 'Southern Province', '198'),
    ('913', 'Western Area', '198'),
    ('914', 'Eastern Province', '198'),
    ('915', 'Hiran', '203'), -- Hiiraan
    ('916', 'Mudug', '203'),
    ('917', 'Bakool', '203'),
    ('918', 'Galguduud', '203'),
    ('919', 'Sanaag', '203'), -- Removed Region, Sanaag has 'S' not 'Ṣ'
    ('920', 'Nugal', '203'),
    ('921', 'Lower Shabelle', '203'),
    ('922', 'Middle Juba', '203'), -- Jubbada Dhexe
    ('923', 'Middle Shabelle', '203'), -- Shabeellaha Dhexe
    ('924', 'Lower Juba', '203'), -- Jubbada Hoose
    ('925', 'Awdal', '203'), -- Removed Region
    ('926', 'Bay', '203'),
    ('927', 'Banaadir', '203'),
    ('928', 'Gedo', '203'),
    ('929', 'Togdheer', '203'), -- Removed Region
    ('930', 'Bari', '203'),
    ('931', 'Northern Cape', '204'),
    ('932', 'Free State', '204'),
    ('933', 'Limpopo', '204'),
    ('934', 'North West', '204'),
    ('935', 'KwaZulu-Natal', '204'),
    ('936', 'Gauteng', '204'),
    ('937', 'Mpumalanga', '204'),
    ('938', 'Eastern Cape', '204'),
    ('939', 'Western Cape', '204'),
    ('940', 'Chontales Department', '159'),
    ('941', 'Managua Department', '159'),
    ('942', 'Rivas Department', '159'),
    ('943', 'Granada Department', '159'),
    ('944', 'León Department', '159'), -- León has 'ó'
    ('945', 'Estelí Department', '159'), -- Estelí has 'í'
    ('946', 'Boaco Department', '159'),
    ('947', 'Matagalpa Department', '159'),
    ('948', 'Madriz Department', '159'),
    ('949', 'Río San Juan Department', '159'), -- Río has 'í'
    ('950', 'Carazo Department', '159'),
    (
        '951',
        'North Caribbean Coast Autonomous Region',
        '159'
    ),
    (
        '952',
        'South Caribbean Coast Autonomous Region',
        '159'
    ),
    ('953', 'Masaya Department', '159'),
    ('954', 'Chinandega Department', '159'),
    ('955', 'Jinotega Department', '159'),
    ('956', 'Karak Governorate', '111'),
    ('957', 'Tafilah Governorate', '111'),
    ('958', 'Madaba Governorate', '111'),
    ('959', 'Aqaba Governorate', '111'),
    ('960', 'Irbid Governorate', '111'),
    ('961', 'Balqa Governorate', '111'),
    ('962', 'Mafraq Governorate', '111'),
    ('963', 'Ajloun Governorate', '111'),
    ('964', 'Ma''an Governorate', '111'), -- Ma'an has apostrophe
    ('965', 'Amman Governorate', '111'),
    ('966', 'Jerash Governorate', '111'),
    ('967', 'Zarqa Governorate', '111'),
    ('968', 'Manzini District', '212'),
    ('969', 'Hhohho District', '212'),
    ('970', 'Lubombo District', '212'),
    ('971', 'Shiselweni District', '212'),
    ('972', 'Al Jahra Governorate', '117'),
    ('973', 'Hawalli Governorate', '117'),
    ('974', 'Mubarak Al-Kabeer Governorate', '117'),
    ('975', 'Al Farwaniyah Governorate', '117'),
    ('976', 'Capital Governorate', '117'),
    ('977', 'Al Ahmadi Governorate', '117'),
    ('978', 'Luang Prabang Province', '119'),
    ('979', 'Vientiane Prefecture', '119'),
    ('980', 'Vientiane Province', '119'),
    ('981', 'Salavan Province', '119'),
    ('982', 'Attapeu Province', '119'),
    ('983', 'Xaisomboun Province', '119'), -- Saysomboun
    ('984', 'Sekong Province', '119'),
    ('985', 'Bolikhamsai Province', '119'),
    ('986', 'Khammouane Province', '119'),
    ('987', 'Phongsaly Province', '119'),
    ('988', 'Oudomxay Province', '119'),
    ('989', 'Houaphanh Province', '119'),
    ('990', 'Savannakhet Province', '119'),
    ('991', 'Bokeo Province', '119'),
    ('992', 'Luang Namtha Province', '119'),
    ('993', 'Sainyabuli Province', '119'), -- Xaignabouli
    (
        '994',
        'Xaisomboun Special Zone (historical)',
        '119'
    ), -- Changed Xaisomboun to reflect its status change (was special zone, now province ID 983)
    ('995', 'Xiangkhouang Province', '119'),
    ('996', 'Champasak Province', '119'),
    ('997', 'Talas Region', '118'),
    ('998', 'Batken Region', '118'),
    ('999', 'Naryn Region', '118'),
    ('1000', 'Jalal-Abad Region', '118'),
    ('1001', 'Bishkek City', '118'), -- Changed Bishkek to Bishkek City (official status)
    ('1002', 'Issyk-Kul Region', '118'),
    ('1003', 'Osh City', '118'), -- Changed Osh to Osh City (official status)
    ('1004', 'Chuy Region', '118'), -- Chüy
    ('1005', 'Osh Region', '118'),
    ('1006', 'Trøndelag', '165'), -- Trøndelag has 'ø'
    ('1007', 'Oslo', '165'),
    ('1008', 'Vestfold og Telemark', '165'), -- Merged Vestfold and Telemark (2020). Corrected Vestfold.
    ('1009', 'Innlandet', '165'), -- Merged Oppland and Hedmark (2020). Corrected Oppland.
    ('1010', 'Sør-Trøndelag (historical)', '165'), -- Sør-Trøndelag has 'ø', Added (historical)
    ('1011', 'Viken', '165'), -- Merged Buskerud, Akershus, Østfold (2020). Corrected Buskerud.
    ('1012', 'Nord-Trøndelag (historical)', '165'), -- Added (historical)
    ('1013', 'Svalbard', '165'),
    ('1014', 'Agder', '165'), -- Merged Vest-Agder and Aust-Agder (2020). Corrected Vest-Agder.
    ('1015', 'Troms og Finnmark', '165'), -- Merged Troms and Finnmark (2020). Corrected Troms. ('og' means 'and')
    ('1016', 'Finnmark (historical)', '165'), -- Added (historical)
    ('1017', 'Akershus (historical)', '165'), -- Added (historical)
    ('1018', 'Vestland', '165'), -- Merged Sogn og Fjordane and Hordaland (2020). Corrected Sogn og Fjordane.
    ('1019', 'Hedmark (historical)', '165'), -- Added (historical)
    ('1020', 'Møre og Romsdal', '165'), -- Møre has 'ø'
    ('1021', 'Rogaland', '165'),
    ('1022', 'Østfold (historical)', '165'), -- Østfold has 'Ø', Added (historical)
    ('1023', 'Hordaland (historical)', '165'), -- Added (historical)
    ('1024', 'Telemark (historical)', '165'), -- Added (historical)
    ('1025', 'Nordland', '165'),
    ('1026', 'Jan Mayen', '165'),
    ('1027', 'Hódmezővásárhely', '99'), -- Hódmezővásárhely has 'ó', 'ő', 'á' (City with county rights)
    ('1028', 'Érd', '99'), -- Érd has 'É' (City with county rights)
    ('1029', 'Szeged', '99'), -- (City with county rights)
    ('1030', 'Nagykanizsa', '99'), -- (City with county rights)
    ('1031', 'Csongrád-Csanád County', '99'), -- Csongrád has 'á', Changed Csongrád County to Csongrád-Csanád County (official name change 2020)
    ('1032', 'Debrecen', '99'), -- (City with county rights)
    ('1033', 'Székesfehérvár', '99'), -- Székesfehérvár has 'é', '
    ('1034', 'Nyíregyháza', '99'), -- Nyíregyháza has 'í', 'á' (City with county rights)
    ('1035', 'Somogy County', '99'),
    ('1036', 'Békéscsaba', '99'), -- Békéscsaba has 'é' (City with county rights)
    ('1037', 'Eger', '99'), -- (City with county rights)
    ('1038', 'Tolna County', '99'),
    ('1039', 'Vas County', '99'),
    ('1040', 'Heves County', '99'),
    ('1041', 'Győr', '99'), -- Győr has 'ő' (City with county rights)
    ('1042', 'Győr-Moson-Sopron County', '99'), -- Győr has 'ő'
    ('1043', 'Jász-Nagykun-Szolnok County', '99'), -- Jász has 'á'
    ('1044', 'Fejér County', '99'), -- Fejér has 'é'
    ('1045', 'Szabolcs-Szatmár-Bereg County', '99'), -- Szabolcs has 'á'
    ('1046', 'Zala County', '99'),
    ('1047', 'Szolnok', '99'), -- (City with county rights)
    ('1048', 'Bács-Kiskun County', '99'), -- Bács has 'á'
    ('1049', 'Dunaújváros', '99'), -- Dunaújváros has 'ú', 'á' (City with county rights)
    ('1050', 'Zalaegerszeg', '99'), -- (City with county rights)
    ('1051', 'Nógrád County', '99'), -- Nógrád has 'ó', 'á'
    ('1052', 'Szombathely', '99'), -- (City with county rights)
    ('1053', 'Pécs', '99'), -- Pécs has 'é' (City with county rights)
    ('1054', 'Veszprém County', '99'), -- Veszprém has 'é'
    ('1055', 'Baranya County', '99'),
    ('1056', 'Kecskemét', '99'), -- Kecskemét has 'é' (City with county rights)
    ('1057', 'Sopron', '99'), -- (City with county rights)
    ('1058', 'Borsod-Abaúj-Zemplén County', '99'), -- Abaúj has 'ú', Zemplén has 'é'
    ('1059', 'Pest County', '99'),
    ('1060', 'Békés County', '99'), -- Békés has 'é'
    ('1061', 'Szekszárd', '99'), -- Szekszárd has 'á' (City with county rights)
    ('1062', 'Veszprém', '99'), -- Veszprém has 'é' (City with county rights)
    ('1063', 'Hajdú-Bihar County', '99'), -- Hajdú has 'ú'
    ('1064', 'Budapest', '99'),
    ('1065', 'Miskolc', '99'), -- (City with county rights)
    ('1066', 'Tatabánya', '99'), -- Tatabánya has 'á' (City with county rights)
    ('1067', 'Kaposvár', '99'), -- Kaposvár has 'á' (City with county rights)
    ('1068', 'Salgótarján', '99'), -- Salgótarján has 'ó', 'á' (City with county rights)
    ('1069', 'County Tipperary', '105'),
    ('1070', 'County Sligo', '105'),
    ('1071', 'County Donegal', '105'),
    ('1072', 'County Dublin', '105'), -- Note: Abolished as admin unit, split into Dublin City, Dún Laoghaire–Rathdown, Fingal, South Dublin. Keeping for context.
    ('1073', 'Leinster', '105'), -- Province
    ('1074', 'County Cork', '105'),
    ('1075', 'County Monaghan', '105'),
    ('1076', 'County Longford', '105'),
    ('1077', 'County Kerry', '105'),
    ('1078', 'County Offaly', '105'),
    ('1079', 'County Galway', '105'),
    ('1080', 'Munster', '105'), -- Province
    ('1081', 'County Roscommon', '105'),
    ('1082', 'County Kildare', '105'),
    ('1083', 'County Louth', '105'),
    ('1084', 'County Mayo', '105'),
    ('1085', 'County Wicklow', '105'),
    ('1086', 'Ulster', '105'), -- Province (partially in Rep. of Ireland)
    ('1087', 'Connacht', '105'), -- Province
    ('1088', 'County Cavan', '105'),
    ('1089', 'County Waterford', '105'),
    ('1090', 'County Kilkenny', '105'),
    ('1091', 'County Clare', '105'),
    ('1092', 'County Meath', '105'),
    ('1093', 'County Wexford', '105'),
    ('1094', 'County Limerick', '105'),
    ('1095', 'County Carlow', '105'),
    ('1096', 'County Laois', '105'),
    ('1097', 'County Westmeath', '105'),
    ('1098', 'Djelfa Province', '4'),
    ('1099', 'El Oued Province', '4'),
    ('1100', 'El Tarf Province', '4'),
    ('1101', 'Oran Province', '4'),
    ('1102', 'Naama Province', '4'), -- Naâma
    ('1103', 'Annaba Province', '4'),
    ('1104', 'Bouïra Province', '4'), -- Bouïra has 'ï'
    ('1105', 'Chlef Province', '4'),
    ('1106', 'Tiaret Province', '4'),
    ('1107', 'Tlemcen Province', '4'),
    ('1108', 'Béchar Province', '4'), -- Béchar has 'é'
    ('1109', 'Médéa Province', '4'), -- Médéa has 'é'
    ('1110', 'Skikda Province', '4'),
    ('1111', 'Blida Province', '4'),
    ('1112', 'Illizi Province', '4'),
    ('1113', 'Jijel Province', '4'),
    ('1114', 'Biskra Province', '4'), -- Changed Biskra to Biskra Province
    ('1115', 'Tipaza Province', '4'),
    ('1116', 'Bordj Bou Arréridj Province', '4'), -- Arréridj has 'é'
    ('1117', 'Tébessa Province', '4'), -- Tébessa has 'é'
    ('1118', 'Adrar Province', '4'),
    ('1119', 'Aïn Defla Province', '4'), -- Aïn has 'ï'
    ('1120', 'Tindouf Province', '4'),
    ('1121', 'Constantine Province', '4'),
    ('1122', 'Aïn Témouchent Province', '4'), -- Aïn has 'ï', Témouchent has 'é'
    ('1123', 'Saïda Province', '4'), -- Saïda has 'ï'
    ('1124', 'Mascara Province', '4'),
    ('1125', 'Boumerdès Province', '4'), -- Boumerdès has 'è'
    ('1126', 'Khenchela Province', '4'),
    ('1127', 'Ghardaïa Province', '4'), -- Ghardaïa has 'ï'
    ('1128', 'Béjaïa Province', '4'), -- Béjaïa has 'é', 'ï'
    ('1129', 'El Bayadh Province', '4'),
    ('1130', 'Relizane Province', '4'),
    ('1131', 'Tizi Ouzou Province', '4'),
    ('1132', 'Mila Province', '4'),
    ('1133', 'Tissemsilt Province', '4'),
    ('1134', 'M''Sila Province', '4'), -- Fixed M'Sila -> M'Sila with apostrophe
    ('1135', 'Tamanrasset Province', '4'), -- Changed Tamanghasset to Tamanrasset
    ('1136', 'Oum El Bouaghi Province', '4'),
    ('1137', 'Guelma Province', '4'),
    ('1138', 'Laghouat Province', '4'),
    ('1139', 'Ouargla Province', '4'),
    ('1140', 'Mostaganem Province', '4'),
    ('1141', 'Sétif Province', '4'), -- Sétif has 'é'
    ('1142', 'Batna Province', '4'),
    ('1143', 'Souk Ahras Province', '4'),
    ('1144', 'Algiers Province', '4'),
    ('1145', 'Region of Murcia', '207'), -- Changed Murcia Province to Region of Murcia (Autonomous Community)
    ('1146', 'Burgos Province', '207'),
    ('1147', 'Salamanca Province', '207'),
    ('1148', 'Álava / Araba', '207'), -- Changed Araba / Álava to Álava / Araba (common order), Álava has 'Á', 'á'
    ('1149', 'Madrid Province (historical)', '207'), -- Changed Madrid Province to Madrid Province (historical) as it's now Community of Madrid
    ('1150', 'Ciudad Real Province', '207'),
    ('1151', 'Almería Province', '207'), -- Almería has 'í'
    ('1152', 'Valencia Province', '207'),
    ('1153', 'Badajoz Province', '207'),
    ('1154', 'Pontevedra Province', '207'),
    ('1155', 'Seville Province', '207'),
    ('1156', 'Alicante Province', '207'),
    ('1157', 'Palencia Province', '207'),
    ('1158', 'Community of Madrid', '207'),
    ('1159', 'Melilla', '207'), -- Autonomous city
    ('1160', 'Asturias', '207'), -- Changed Province of Asturias to Asturias (Autonomous Community)
    ('1161', 'Zamora Province', '207'),
    ('1162', 'Zaragoza Province', '207'),
    ('1163', 'Huesca Province', '207'),
    ('1164', 'Tarragona Province', '207'),
    ('1165', 'Toledo Province', '207'),
    ('1166', 'Las Palmas Province', '207'),
    ('1167', 'Galicia', '207'), -- Autonomous Community
    ('1168', 'Albacete Province', '207'),
    ('1169', 'Cuenca Province', '207'),
    ('1170', 'Cantabria', '207'), -- Autonomous Community
    ('1171', 'La Rioja', '207'), -- Autonomous Community
    ('1172', 'Guadalajara Province', '207'),
    ('1173', 'Ourense Province', '207'),
    ('1174', 'Balearic Islands', '207'), -- Autonomous Community / Province
    ('1175', 'Valencian Community', '207'), -- Autonomous Community
    ('1176', 'Region of Murcia', '207'), -- Autonomous Community
    ('1177', 'Aragon', '207'), -- Aragón (Autonomous Community)
    ('1178', 'Girona Province', '207'),
    ('1179', 'A Coruña Province', '207'), -- Coruña has 'ñ'
    ('1180', 'Barcelona Province', '207'),
    ('1181', 'Jaén Province', '207'), -- Jaén has 'é'
    ('1182', 'Teruel Province', '207'),
    ('1183', 'Valladolid Province', '207'),
    ('1184', 'Castile and León', '207'), -- Castile and León (Castilla y León) Autonomous Community, León has 'ó'
    ('1185', 'Canary Islands', '207'), -- Autonomous Community
    ('1186', 'Biscay', '207'), -- Province (Bizkaia)
    ('1187', 'Lugo Province', '207'),
    ('1188', 'Málaga Province', '207'), -- Málaga has 'á'
    ('1189', 'Ávila Province', '207'), -- Changed Province of Ávila to Ávila Province, Ávila has 'Á', 'á'
    ('1190', 'Extremadura', '207'), -- Autonomous Community
    ('1191', 'Basque Country', '207'), -- Autonomous Community (Euskadi)
    ('1192', 'Segovia Province', '207'),
    ('1193', 'Andalusia', '207'), -- Andalucía (Autonomous Community)
    ('1194', 'Granada Province', '207'),
    ('1195', 'Lleida Province', '207'),
    ('1196', 'Cáceres Province', '207'), -- Cáceres has 'á'
    ('1197', 'Córdoba Province', '207'), -- Córdoba has 'ó'
    ('1198', 'Santa Cruz de Tenerife Province', '207'),
    ('1199', 'Huelva Province', '207'),
    ('1200', 'León Province', '207'), -- León has 'ó'
    ('1201', 'Cádiz Province', '207'), -- Cádiz has 'á'
    ('1202', 'Gipuzkoa', '207'), -- Province
    ('1203', 'Catalonia', '207'), -- Autonomous Community (Catalunya)
    ('1204', 'Navarre', '207'), -- Chartered Community of Navarre (Navarra)
    ('1205', 'Castilla-La Mancha', '207'), -- Changed Castile-La Mancha to Castilla-La Mancha (Autonomous Community)
    ('1206', 'Ceuta', '207'), -- Autonomous city
    ('1207', 'Castellón Province', '207'), -- Castelló / Castellón
    ('1208', 'Soria Province', '207'),
    ('1209', 'Guanacaste Province', '53'),
    ('1210', 'Puntarenas Province', '53'),
    ('1211', 'Cartago Province', '53'), -- Changed Provincia de Cartago to Cartago Province
    ('1212', 'Heredia Province', '53'),
    ('1213', 'Limón Province', '53'), -- Limón has 'ó'
    ('1214', 'San José Province', '53'), -- José has 'é'
    ('1215', 'Alajuela Province', '53'),
    ('1216', 'Brunei-Muara District', '33'),
    ('1217', 'Belait District', '33'),
    ('1218', 'Temburong District', '33'),
    ('1219', 'Tutong District', '33'),
    ('1220', 'Saint Philip', '20'), -- Parish
    ('1221', 'Saint Lucy', '20'), -- Parish
    ('1222', 'Saint Peter', '20'), -- Parish
    ('1223', 'Saint Joseph', '20'), -- Parish
    ('1224', 'Saint James', '20'), -- Parish
    ('1225', 'Saint Thomas', '20'), -- Parish
    ('1226', 'Saint George', '20'), -- Parish
    ('1227', 'Saint John', '20'), -- Parish
    ('1228', 'Christ Church', '20'), -- Parish
    ('1229', 'Saint Andrew', '20'), -- Parish
    ('1230', 'Saint Michael', '20'), -- Parish
    ('1231', 'Ta''izz Governorate', '245'), -- Fixed Ta'izz -> Ta'izz with apostrophe
    ('1232', 'Sana''a City (Capital)', '245'), -- Changed Sana'a to Sana'a City (Capital) to distinguish from Governorate, Fixed escaping
    ('1233', 'Ibb Governorate', '245'),
    ('1234', 'Ma''rib Governorate', '245'), -- Fixed Ma'rib -> Ma'rib with apostrophe
    ('1235', 'Al Mahwit Governorate', '245'),
    ('1236', 'Sana''a Governorate', '245'), -- Fixed escaping
    ('1237', 'Abyan Governorate', '245'),
    ('1238', 'Hadhramaut Governorate', '245'),
    ('1239', 'Socotra Governorate', '245'),
    ('1240', 'Al Bayda'' Governorate', '245'), -- Fixed escaping
    ('1241', 'Al Hudaydah Governorate', '245'),
    ('1242', '''Adan Governorate', '245'), -- Fixed escaping
    ('1243', 'Al Jawf Governorate', '245'),
    ('1244', 'Hajjah Governorate', '245'),
    ('1245', 'Lahij Governorate', '245'),
    ('1246', 'Dhamar Governorate', '245'),
    ('1247', 'Shabwah Governorate', '245'),
    ('1248', 'Raymah Governorate', '245'),
    ('1249', 'Saada Governorate', '245'), -- Sa'dah
    ('1250', '''Amran Governorate', '245'), -- Fixed escaping
    ('1251', 'Al Mahrah Governorate', '245'),
    ('1252', 'Sangha-Mbaéré', '42'), -- Mbaéré has 'é' (Economic Prefecture)
    ('1253', 'Nana-Grébizi', '42'), -- Grébizi has 'é' (Economic Prefecture)
    ('1254', 'Ouham Prefecture', '42'),
    ('1255', 'Ombella-M''Poko Prefecture', '42'), -- Fixed escaping
    ('1256', 'Lobaye Prefecture', '42'),
    ('1257', 'Mambéré-Kadéï', '42'), -- Kadéï has 'é', 'ï' (Prefecture)
    ('1258', 'Haut-Mbomou Prefecture', '42'),
    ('1259', 'Bamingui-Bangoran Prefecture', '42'),
    ('1260', 'Nana-Mambéré Prefecture', '42'), -- Mambéré has 'é'
    ('1261', 'Vakaga Prefecture', '42'),
    ('1262', 'Bangui', '42'), -- Commune
    ('1263', 'Kémo Prefecture', '42'), -- Kémo has 'é'
    ('1264', 'Basse-Kotto Prefecture', '42'),
    ('1265', 'Ouaka Prefecture', '42'),
    ('1266', 'Mbomou Prefecture', '42'),
    ('1267', 'Ouham-Pendé Prefecture', '42'), -- Pendé has 'é'
    ('1268', 'Haute-Kotto Prefecture', '42'),
    ('1269', 'Romblon', '174'), -- Province
    ('1270', 'Bukidnon', '174'), -- Province
    ('1271', 'Rizal', '174'), -- Province
    ('1272', 'Bohol', '174'), -- Province
    ('1273', 'Quirino', '174'), -- Province
    ('1274', 'Biliran', '174'), -- Province
    ('1275', 'Quezon', '174'), -- Province
    ('1276', 'Siquijor', '174'), -- Province
    ('1277', 'Sarangani', '174'), -- Province
    ('1278', 'Bulacan', '174'), -- Province
    ('1279', 'Cagayan', '174'), -- Province
    ('1280', 'South Cotabato', '174'), -- Province
    ('1281', 'Sorsogon', '174'), -- Province
    ('1282', 'Sultan Kudarat', '174'), -- Province
    ('1283', 'Camarines Norte', '174'), -- Province
    ('1284', 'Southern Leyte', '174'), -- Province
    ('1285', 'Camiguin', '174'), -- Province
    ('1286', 'Surigao del Norte', '174'), -- Province
    ('1287', 'Camarines Sur', '174'), -- Province
    ('1288', 'Sulu', '174'), -- Province
    ('1289', 'Davao Oriental', '174'), -- Province
    ('1290', 'Eastern Samar', '174'), -- Province
    ('1291', 'Dinagat Islands', '174'), -- Province
    ('1292', 'Capiz', '174'), -- Province
    ('1293', 'Tawi-Tawi', '174'), -- Province
    ('1294', 'Calabarzon', '174'), -- Region
    ('1295', 'Tarlac', '174'), -- Province
    ('1296', 'Surigao del Sur', '174'), -- Province
    ('1297', 'Zambales', '174'), -- Province
    ('1298', 'Ilocos Norte', '174'), -- Province
    ('1299', 'Mimaropa', '174'), -- Region
    ('1300', 'Ifugao', '174'), -- Province
    ('1301', 'Catanduanes', '174'), -- Province
    ('1302', 'Zamboanga del Norte', '174'), -- Province
    ('1303', 'Guimaras', '174'), -- Province
    ('1304', 'Bicol Region', '174'), -- Region
    ('1305', 'Western Visayas', '174'), -- Region
    ('1306', 'Cebu', '174'), -- Province
    ('1307', 'Cavite', '174'), -- Province
    ('1308', 'Central Visayas', '174'), -- Region
    ('1309', 'Davao Occidental', '174'), -- Province
    ('1310', 'Soccsksargen', '174'), -- Region
    ('1311', 'Davao de Oro', '174'), -- Changed Compostela Valley to Davao de Oro (official name change 2019)
    ('1312', 'Kalinga', '174'), -- Province
    ('1313', 'Isabela', '174'), -- Province
    ('1314', 'Caraga', '174'), -- Region
    ('1315', 'Iloilo', '174'), -- Province
    (
        '1316',
        'Bangsamoro Autonomous Region in Muslim Mindanao',
        '174'
    ), -- Changed Autonomous Region in Muslim Mindanao to Bangsamoro... (replaced in 2019)
    ('1317', 'La Union', '174'), -- Province
    ('1318', 'Davao del Sur', '174'), -- Province
    ('1319', 'Davao del Norte', '174'), -- Province
    ('1320', 'Cotabato', '174'), -- Province (also known as North Cotabato)
    ('1321', 'Ilocos Sur', '174'), -- Province
    ('1322', 'Eastern Visayas', '174'), -- Region
    ('1323', 'Agusan del Norte', '174'), -- Province
    ('1324', 'Abra', '174'), -- Province
    ('1325', 'Zamboanga Peninsula', '174'), -- Region
    ('1326', 'Agusan del Sur', '174'), -- Province
    ('1327', 'Lanao del Norte', '174'), -- Province
    ('1328', 'Laguna', '174'), -- Province
    ('1329', 'Marinduque', '174'), -- Province
    ('1330', 'Maguindanao', '174'), -- Province (Note: Split into Maguindanao del Norte and Maguindanao del Sur in 2022, part of BARMM)
    ('1331', 'Aklan', '174'), -- Province
    ('1332', 'Leyte', '174'), -- Province
    ('1333', 'Lanao del Sur', '174'), -- Province (Part of BARMM)
    ('1334', 'Apayao', '174'), -- Province
    ('1335', 'Cordillera Administrative Region', '174'), -- Region
    ('1336', 'Antique', '174'), -- Province
    ('1337', 'Albay', '174'), -- Province
    ('1338', 'Masbate', '174'), -- Province
    ('1339', 'Northern Mindanao', '174'), -- Region
    ('1340', 'Davao Region', '174'), -- Region
    ('1341', 'Aurora', '174'), -- Province
    ('1342', 'Cagayan Valley', '174'), -- Region
    ('1343', 'Misamis Occidental', '174'), -- Province
    ('1344', 'Bataan', '174'), -- Province
    ('1345', 'Central Luzon', '174'), -- Region
    ('1346', 'Basilan', '174'), -- Province (Part of BARMM, excl. Isabela City)
    ('1347', 'Metro Manila', '174'), -- National Capital Region (NCR)
    ('1348', 'Misamis Oriental', '174'), -- Province
    ('1349', 'Northern Samar', '174'), -- Province
    ('1350', 'Negros Oriental', '174'), -- Province
    ('1351', 'Negros Occidental', '174'), -- Province
    ('1352', 'Batanes', '174'), -- Province
    ('1353', 'Mountain Province', '174'), -- Province
    ('1354', 'Oriental Mindoro', '174'), -- Province
    ('1355', 'Ilocos Region', '174'), -- Region
    ('1356', 'Occidental Mindoro', '174'), -- Province
    ('1357', 'Zamboanga del Sur', '174'), -- Province
    ('1358', 'Nueva Vizcaya', '174'), -- Province
    ('1359', 'Batangas', '174'), -- Province
    ('1360', 'Nueva Ecija', '174'), -- Province
    ('1361', 'Palawan', '174'), -- Province
    ('1362', 'Zamboanga Sibugay', '174'), -- Province
    ('1363', 'Benguet', '174'), -- Province
    ('1364', 'Pangasinan', '174'), -- Province
    ('1365', 'Pampanga', '174'), -- Province
    ('1366', 'Northern District', '106'),
    ('1367', 'Central District', '106'),
    ('1368', 'Southern District', '106'),
    ('1369', 'Haifa District', '106'),
    ('1370', 'Jerusalem District', '106'),
    ('1371', 'Tel Aviv District', '106'),
    ('1372', 'Limburg', '22'), -- Province (Flanders)
    ('1373', 'Flanders', '22'), -- Region
    ('1374', 'Flemish Brabant', '22'), -- Province (Flanders)
    ('1375', 'Hainaut', '22'), -- Province (Wallonia)
    ('1376', 'Brussels-Capital Region', '22'), -- Region
    ('1377', 'East Flanders', '22'), -- Province (Flanders)
    ('1378', 'Namur', '22'), -- Province (Wallonia)
    ('1379', 'Luxembourg', '22'), -- Province (Wallonia)
    ('1380', 'Wallonia', '22'), -- Region
    ('1381', 'Antwerp', '22'), -- Province (Flanders)
    ('1382', 'Walloon Brabant', '22'), -- Province (Wallonia)
    ('1383', 'West Flanders', '22'), -- Province (Flanders)
    ('1384', 'Liège', '22'), -- Province (Wallonia), Liège has 'è'
    ('1385', 'Darién Province', '170'), -- Darién has 'é'
    ('1386', 'Colón Province', '170'), -- Colón has 'ó'
    ('1387', 'Coclé Province', '170'), -- Coclé has 'é'
    ('1388', 'Guna Yala', '170'), -- Comarca indígena
    ('1389', 'Herrera Province', '170'),
    ('1390', 'Los Santos Province', '170'),
    ('1391', 'Ngäbe-Buglé Comarca', '170'), -- Changed Ngöbe-Buglé to Ngäbe-Buglé (official spelling 'ä'), Comarca indígena
    ('1392', 'Veraguas Province', '170'),
    ('1393', 'Bocas del Toro Province', '170'),
    ('1394', 'Panamá Oeste Province', '170'), -- Panamá has 'á'
    ('1395', 'Panamá Province', '170'), -- Panamá has 'á'
    ('1396', 'Emberá-Wounaan Comarca', '170'), -- Emberá has 'á', Wounaan (Comarca indígena)
    ('1397', 'Chiriquí Province', '170'), -- Chiriquí has 'í'
    ('1398', 'Howland Island', '233'), -- U.S. Minor Outlying Island
    ('1399', 'Delaware', '233'), -- State
    ('1400', 'Alaska', '233'), -- State
    ('1401', 'Maryland', '233'), -- State
    ('1402', 'Baker Island', '233'), -- U.S. Minor Outlying Island
    ('1403', 'Kingman Reef', '233'), -- U.S. Minor Outlying Island
    ('1404', 'New Hampshire', '233'), -- State
    ('1405', 'Wake Island', '233'), -- U.S. Minor Outlying Island
    ('1406', 'Kansas', '233'), -- State
    ('1407', 'Texas', '233'), -- State
    ('1408', 'Nebraska', '233'), -- State
    ('1409', 'Vermont', '233'), -- State
    ('1410', 'Jarvis Island', '233'), -- U.S. Minor Outlying Island
    ('1411', 'Hawaii', '233'), -- State (Hawaiʻi)
    ('1412', 'Guam', '233'), -- Territory
    ('1413', 'United States Virgin Islands', '233'), -- Territory
    ('1414', 'Utah', '233'), -- State
    ('1415', 'Oregon', '233'), -- State
    ('1416', 'California', '233'), -- State
    ('1417', 'New Jersey', '233'), -- State
    ('1418', 'North Dakota', '233'), -- State
    ('1419', 'Kentucky', '233'), -- State (Commonwealth)
    ('1420', 'Minnesota', '233'), -- State
    ('1421', 'Oklahoma', '233'), -- State
    ('1422', 'Pennsylvania', '233'), -- State (Commonwealth)
    ('1423', 'New Mexico', '233'), -- State
    ('1424', 'American Samoa', '233'), -- Territory
    ('1425', 'Illinois', '233'), -- State
    ('1426', 'Michigan', '233'), -- State
    ('1427', 'Virginia', '233'), -- State (Commonwealth)
    ('1428', 'Johnston Atoll', '233'), -- U.S. Minor Outlying Island
    ('1429', 'West Virginia', '233'), -- State
    ('1430', 'Mississippi', '233'), -- State
    ('1431', 'Northern Mariana Islands', '233'), -- Territory (Commonwealth)
    (
        '1432',
        'United States Minor Outlying Islands',
        '233'
    ), -- Statistical designation
    ('1433', 'Massachusetts', '233'), -- State (Commonwealth)
    ('1434', 'Arizona', '233'), -- State
    ('1435', 'Connecticut', '233'), -- State
    ('1436', 'Florida', '233'), -- State
    ('1437', 'District of Columbia', '233'), -- Federal District
    ('1438', 'Midway Atoll', '233'), -- U.S. Minor Outlying Island
    ('1439', 'Navassa Island', '233'), -- U.S. Minor Outlying Island
    ('1440', 'Indiana', '233'), -- State
    ('1441', 'Wisconsin', '233'), -- State
    ('1442', 'Wyoming', '233'), -- State
    ('1443', 'South Carolina', '233'), -- State
    ('1444', 'Arkansas', '233'), -- State
    ('1445', 'South Dakota', '233'), -- State
    ('1446', 'Montana', '233'), -- State
    ('1447', 'North Carolina', '233'), -- State
    ('1448', 'Palmyra Atoll', '233'), -- U.S. Minor Outlying Island
    ('1449', 'Puerto Rico', '233'), -- Territory (Commonwealth)
    ('1450', 'Colorado', '233'), -- State
    ('1451', 'Missouri', '233'), -- State
    ('1452', 'New York', '233'), -- State
    ('1453', 'Maine', '233'), -- State
    ('1454', 'Tennessee', '233'), -- State
    ('1455', 'Georgia', '233'), -- State
    ('1456', 'Alabama', '233'), -- State
    ('1457', 'Louisiana', '233'), -- State
    ('1458', 'Nevada', '233'), -- State
    ('1459', 'Iowa', '233'), -- State
    ('1460', 'Idaho', '233'), -- State
    ('1461', 'Rhode Island', '233'), -- State
    ('1462', 'Washington', '233'), -- State
    ('1463', 'Shinyanga Region', '218'),
    ('1464', 'Simiyu Region', '218'),
    ('1465', 'Kagera Region', '218'),
    ('1466', 'Dodoma Region', '218'), -- Capital Region
    ('1467', 'Kilimanjaro Region', '218'),
    ('1468', 'Mara Region', '218'),
    ('1469', 'Tabora Region', '218'),
    ('1470', 'Morogoro Region', '218'),
    ('1471', 'Unguja South Region', '218'), -- Zanzibar South and Central, Changed Zanzibar Central/South Region to Unguja South Region (official name)
    ('1472', 'Pemba South Region', '218'), -- Changed South Pemba Region to Pemba South Region
    ('1473', 'Unguja North Region', '218'), -- Changed Zanzibar North Region to Unguja North Region
    ('1474', 'Singida Region', '218'),
    ('1475', 'Unguja Urban West Region', '218'), -- Changed Zanzibar Urban/West Region to Unguja Urban West Region
    ('1476', 'Mtwara Region', '218'),
    ('1477', 'Rukwa Region', '218'),
    ('1478', 'Kigoma Region', '218'),
    ('1479', 'Mwanza Region', '218'),
    ('1480', 'Njombe Region', '218'),
    ('1481', 'Geita Region', '218'),
    ('1482', 'Katavi Region', '218'),
    ('1483', 'Lindi Region', '218'),
    ('1484', 'Manyara Region', '218'),
    ('1485', 'Pwani Region', '218'), -- Coast Region
    ('1486', 'Ruvuma Region', '218'),
    ('1487', 'Tanga Region', '218'),
    ('1488', 'Pemba North Region', '218'), -- Changed North Pemba Region to Pemba North Region
    ('1489', 'Iringa Region', '218'),
    ('1490', 'Dar es Salaam Region', '218'),
    ('1491', 'Arusha Region', '218'),
    (
        '1492',
        'Eastern Finland Province (historical)',
        '74'
    ), -- Province abolished 2010, Added (historical)
    ('1493', 'Tavastia Proper', '74'), -- Kanta-Häme (Region)
    ('1494', 'Central Ostrobothnia', '74'), -- Keski-Pohjanmaa (Region)
    ('1495', 'Southern Savonia', '74'), -- Etelä-Savo (Region)
    ('1496', 'Kainuu', '74'), -- Region
    ('1497', 'South Karelia', '74'), -- Etelä-Karjala (Region)
    ('1498', 'Southern Ostrobothnia', '74'), -- Etelä-Pohjanmaa (Region)
    ('1499', 'Oulu Province (historical)', '74'), -- Province abolished 2010, Added (historical)
    ('1500', 'Lapland', '74'), -- Lappi (Region)
    ('1501', 'Satakunta', '74'), -- Region
    ('1502', 'Päijät-Häme', '74'), -- Changed Päijänne Tavastia to Päijät-Häme (Region)
    ('1503', 'Northern Savonia', '74'), -- Pohjois-Savo (Region)
    ('1504', 'North Karelia', '74'), -- Pohjois-Karjala (Region)
    ('1505', 'Northern Ostrobothnia', '74'), -- Pohjois-Pohjanmaa (Region)
    ('1506', 'Pirkanmaa', '74'), -- Region (Tampere Region)
    ('1507', 'Finland Proper', '74'), -- Varsinais-Suomi (Region)
    ('1508', 'Ostrobothnia', '74'), -- Pohjanmaa (Region)
    ('1509', 'Åland Islands', '74'), -- Ahvenanmaa (Autonomous Region)
    ('1510', 'Uusimaa', '74'), -- Region
    ('1511', 'Central Finland', '74'), -- Keski-Suomi (Region)
    ('1512', 'Kymenlaakso', '74'), -- Region
    ('1513', 'Canton of Diekirch', '127'),
    ('1514', 'Luxembourg District (historical)', '127'), -- District abolished 2015, Added (historical)
    ('1515', 'Canton of Echternach', '127'),
    ('1516', 'Canton of Redange', '127'),
    ('1517', 'Canton of Esch-sur-Alzette', '127'),
    ('1518', 'Canton of Capellen', '127'),
    ('1519', 'Canton of Remich', '127'),
    (
        '1520',
        'Grevenmacher District (historical)',
        '127'
    ), -- District abolished 2015, Added (historical)
    ('1521', 'Canton of Clervaux', '127'),
    ('1522', 'Canton of Mersch', '127'),
    ('1523', 'Canton of Vianden', '127'),
    ('1524', 'Diekirch District (historical)', '127'), -- District abolished 2015, Added (historical)
    ('1525', 'Canton of Grevenmacher', '127'),
    ('1526', 'Canton of Wiltz', '127'),
    ('1527', 'Canton of Luxembourg', '127'),
    ('1528', 'Region Zealand', '59'), -- Region Sjælland
    ('1529', 'Region of Southern Denmark', '59'), -- Region Syddanmark
    ('1530', 'Capital Region of Denmark', '59'), -- Region Hovedstaden
    ('1531', 'Central Denmark Region', '59'), -- Region Midtjylland
    ('1532', 'North Denmark Region', '59'), -- Region Nordjylland
    ('1533', 'Gävleborg County', '213'), -- Gävleborg has 'ä'
    ('1534', 'Dalarna County', '213'),
    ('1535', 'Värmland County', '213'), -- Värmland has 'ä'
    ('1536', 'Östergötland County', '213'), -- Östergötland has 'Ö', 'ö'
    ('1537', 'Blekinge County', '213'), -- Changed Blekinge to Blekinge County
    ('1538', 'Norrbotten County', '213'),
    ('1539', 'Örebro County', '213'), -- Örebro has 'Ö', 'ö'
    ('1540', 'Södermanland County', '213'), -- Södermanland has 'ö'
    ('1541', 'Skåne County', '213'), -- Skåne has 'å'
    ('1542', 'Kronoberg County', '213'),
    ('1543', 'Västerbotten County', '213'), -- Västerbotten has 'ä'
    ('1544', 'Kalmar County', '213'),
    ('1545', 'Uppsala County', '213'),
    ('1546', 'Gotland County', '213'),
    ('1547', 'Västra Götaland County', '213'), -- Västra has 'ä', Götaland has 'ö'
    ('1548', 'Halland County', '213'),
    ('1549', 'Västmanland County', '213'), -- Västmanland has 'ä'
    ('1550', 'Jönköping County', '213'), -- Jönköping has 'ö'
    ('1551', 'Stockholm County', '213'),
    ('1552', 'Västernorrland County', '213'), -- Västernorrland has 'ä'
    ('1553', 'Plungė District Municipality', '126'), -- Plungė has 'ė'
    ('1554', 'Šiauliai District Municipality', '126'), -- Šiauliai has 'Š'
    ('1555', 'Jurbarkas District Municipality', '126'),
    ('1556', 'Kaunas County', '126'),
    ('1557', 'Mažeikiai District Municipality', '126'), -- Mažeikiai has 'ž'
    ('1558', 'Panevėžys County', '126'), -- Panevėžys has 'ė', 'ž'
    ('1559', 'Elektrėnai Municipality', '126'), -- Elektrėnai has 'ė'
    ('1560', 'Švenčionys District Municipality', '126'), -- Švenčionys has 'Š', 'č'
    ('1561', 'Akmenė District Municipality', '126'), -- Akmenė has 'ė'
    ('1562', 'Ignalina District Municipality', '126'),
    ('1563', 'Neringa Municipality', '126'),
    ('1564', 'Visaginas Municipality', '126'),
    ('1565', 'Kaunas District Municipality', '126'),
    ('1566', 'Biržai District Municipality', '126'), -- Biržai has 'ž'
    ('1567', 'Jonava District Municipality', '126'),
    (
        '1568',
        'Radviliškis District Municipality',
        '126'
    ), -- Radviliškis has 'š'
    ('1569', 'Telšiai County', '126'), -- Telšiai has 'š'
    ('1570', 'Marijampolė County', '126'), -- Marijampolė has 'ė'
    ('1571', 'Kretinga District Municipality', '126'),
    ('1572', 'Tauragė District Municipality', '126'), -- Tauragė has 'ė'
    ('1573', 'Tauragė County', '126'), -- Tauragė has 'ė'
    ('1574', 'Alytus County', '126'),
    ('1575', 'Kazlų Rūda Municipality', '126'), -- Kazlų has 'ų', Rūda has 'ū'
    ('1576', 'Šakiai District Municipality', '126'), -- Šakiai has 'Š'
    (
        '1577',
        'Šalčininkai District Municipality',
        '126'
    ), -- Šalčininkai has 'Š', 'č'
    ('1578', 'Prienai District Municipality', '126'),
    ('1579', 'Druskininkai Municipality', '126'),
    ('1580', 'Kaunas City Municipality', '126'),
    ('1581', 'Joniškis District Municipality', '126'), -- Joniškis has 'š'
    ('1582', 'Molėtai District Municipality', '126'), -- Molėtai has 'ė'
    (
        '1583',
        'Kaišiadorys District Municipality',
        '126'
    ), -- Kaišiadorys has 'š'
    ('1584', 'Kėdainiai District Municipality', '126'), -- Kėdainiai has 'ė'
    ('1585', 'Kupiškis District Municipality', '126'), -- Kupiškis has 'š'
    ('1586', 'Šiauliai County', '126'), -- Šiauliai has 'Š'
    ('1587', 'Raseiniai District Municipality', '126'),
    ('1588', 'Palanga City Municipality', '126'),
    ('1589', 'Panevėžys City Municipality', '126'), -- Panevėžys has 'ė', 'ž'
    ('1590', 'Rietavas Municipality', '126'),
    ('1591', 'Kalvarija Municipality', '126'),
    ('1592', 'Vilnius District Municipality', '126'),
    ('1593', 'Trakai District Municipality', '126'),
    ('1594', 'Širvintos District Municipality', '126'), -- Širvintos has 'Š'
    ('1595', 'Pakruojis District Municipality', '126'),
    ('1596', 'Ukmergė District Municipality', '126'), -- Ukmergė has 'ė'
    ('1597', 'Klaipėda City Municipality', '126'), -- Klaipėda has 'ė'
    ('1598', 'Utena District Municipality', '126'),
    ('1599', 'Alytus District Municipality', '126'),
    ('1600', 'Klaipėda County', '126'), -- Klaipėda has 'ė'
    ('1601', 'Vilnius County', '126'),
    ('1602', 'Varėna District Municipality', '126'), -- Varėna has 'ė'
    ('1603', 'Birštonas Municipality', '126'), -- Birštonas has 'š'
    ('1604', 'Klaipėda District Municipality', '126'), -- Klaipėda has 'ė'
    ('1605', 'Alytus City Municipality', '126'),
    ('1606', 'Vilnius City Municipality', '126'),
    ('1607', 'Šilutė District Municipality', '126'), -- Šilutė has 'Š', 'ė'
    ('1608', 'Telšiai District Municipality', '126'), -- Telšiai has 'š'
    ('1609', 'Šiauliai City Municipality', '126'), -- Šiauliai has 'Š'
    ('1610', 'Marijampolė Municipality', '126'), -- Marijampolė has 'ė'
    ('1611', 'Lazdijai District Municipality', '126'),
    ('1612', 'Pagėgiai Municipality', '126'), -- Pagėgiai has 'ė'
    ('1613', 'Šilalė District Municipality', '126'), -- Šilalė has 'Š', 'ė'
    ('1614', 'Panevėžys District Municipality', '126'), -- Panevėžys has 'ė', 'ž'
    ('1615', 'Rokiškis District Municipality', '126'), -- Rokiškis has 'š'
    ('1616', 'Pasvalys District Municipality', '126'),
    ('1617', 'Skuodas District Municipality', '126'),
    ('1618', 'Kelmė District Municipality', '126'), -- Kelmė has 'ė'
    ('1619', 'Zarasai District Municipality', '126'),
    (
        '1620',
        'Vilkaviškis District Municipality',
        '126'
    ), -- Vilkaviškis has 'š'
    ('1621', 'Utena County', '126'),
    ('1622', 'Opole Voivodeship', '176'),
    ('1623', 'Silesian Voivodeship', '176'), -- Śląskie
    ('1624', 'Pomeranian Voivodeship', '176'), -- Pomorskie
    ('1625', 'Kuyavian-Pomeranian Voivodeship', '176'), -- Kujawsko-Pomorskie
    ('1626', 'Podkarpackie Voivodeship', '176'), -- Subcarpathian
    ('1627', 'Kielce (historical)', '176'), -- Kielce is a city in Świętokrzyskie Voivodeship, maybe a historical voivodeship reference? Added (historical).
    ('1628', 'Warmian-Masurian Voivodeship', '176'), -- Warmińsko-Mazurskie
    ('1629', 'Lower Silesian Voivodeship', '176'), -- Dolnośląskie
    ('1630', 'Świętokrzyskie Voivodeship', '176'), -- Świętokrzyskie has 'Ś', 'ę'
    ('1631', 'Lubusz Voivodeship', '176'), -- Lubuskie
    ('1632', 'Podlaskie Voivodeship', '176'),
    ('1633', 'West Pomeranian Voivodeship', '176'), -- Zachodniopomorskie
    ('1634', 'Greater Poland Voivodeship', '176'), -- Wielkopolskie
    ('1635', 'Lesser Poland Voivodeship', '176'), -- Małopolskie
    ('1636', 'Łódź Voivodeship', '176'), -- Łódź has 'Ł', 'ó', Łódzkie has 'Ł', 'ó'
    ('1637', 'Masovian Voivodeship', '176'), -- Mazowieckie
    ('1638', 'Lublin Voivodeship', '176'),
    ('1639', 'Aargau', '214'), -- Canton
    ('1640', 'Canton of Fribourg', '214'),
    ('1641', 'Basel-Landschaft', '214'), -- Canton
    ('1642', 'Uri', '214'), -- Canton
    ('1643', 'Ticino', '214'), -- Canton
    ('1644', 'Canton of St. Gallen', '214'),
    ('1645', 'Canton of Bern', '214'), -- Changed canton of Bern to Canton of Bern
    ('1646', 'Canton of Zug', '214'),
    ('1647', 'Canton of Geneva', '214'),
    ('1648', 'Canton of Valais', '214'),
    ('1649', 'Appenzell Innerrhoden', '214'), -- Canton
    ('1650', 'Obwalden', '214'), -- Canton
    ('1651', 'Canton of Vaud', '214'),
    ('1652', 'Nidwalden', '214'), -- Canton
    ('1653', 'Schwyz', '214'), -- Canton
    ('1654', 'Canton of Schaffhausen', '214'),
    ('1655', 'Appenzell Ausserrhoden', '214'), -- Canton
    ('1656', 'Canton of Zürich', '214'), -- Changed canton of Zürich to Canton of Zürich, Zürich has 'ü'
    ('1657', 'Thurgau', '214'), -- Canton
    ('1658', 'Canton of Jura', '214'),
    ('1659', 'Canton of Neuchâtel', '214'), -- Neuchâtel has 'â'
    ('1660', 'Graubünden', '214'), -- Canton (Grisons)
    ('1661', 'Glarus', '214'), -- Canton
    ('1662', 'Canton of Solothurn', '214'),
    ('1663', 'Canton of Lucerne', '214'),
    ('1664', 'Tuscany', '107'), -- Toscana (Region)
    ('1665', 'Province of Padua', '107'), -- Padova
    ('1666', 'Province of Parma', '107'),
    (
        '1667',
        'Free municipal consortium of Syracuse',
        '107'
    ), -- Libero consorzio comunale di Siracusa (replaces Province)
    ('1668', 'Metropolitan City of Palermo', '107'), -- Replaces Province
    ('1669', 'Campania', '107'), -- Region
    ('1670', 'Marche', '107'), -- Region
    (
        '1671',
        'Metropolitan City of Reggio Calabria',
        '107'
    ), -- Replaces Province
    ('1672', 'Province of Ancona', '107'),
    ('1673', 'Metropolitan City of Venice', '107'), -- Replaces Province
    ('1674', 'Province of Latina', '107'),
    ('1675', 'Province of Lecce', '107'),
    ('1676', 'Province of Pavia', '107'),
    ('1677', 'Province of Lecco', '107'),
    ('1678', 'Lazio', '107'), -- Region
    ('1679', 'Abruzzo', '107'), -- Region
    ('1680', 'Metropolitan City of Florence', '107'), -- Replaces Province (Firenze)
    ('1681', 'Province of Ascoli Piceno', '107'),
    ('1682', 'Metropolitan City of Cagliari', '107'), -- Replaces Province
    ('1683', 'Umbria', '107'), -- Region
    ('1684', 'Metropolitan City of Bologna', '107'), -- Replaces Province
    ('1685', 'Province of Pisa', '107'),
    (
        '1686',
        'Province of Barletta-Andria-Trani',
        '107'
    ),
    ('1687', 'Province of Pistoia', '107'),
    ('1688', 'Apulia', '107'), -- Puglia (Region)
    ('1689', 'Province of Belluno', '107'),
    ('1690', 'Province of Pordenone', '107'), -- Abolished 2017, functions transferred
    ('1691', 'Province of Perugia', '107'),
    ('1692', 'Province of Avellino', '107'),
    ('1693', 'Province of Pesaro and Urbino', '107'), -- Changed Pesaro and Urbino Province to Province of Pesaro and Urbino
    ('1694', 'Province of Pescara', '107'),
    ('1695', 'Molise', '107'), -- Region
    ('1696', 'Province of Piacenza', '107'),
    ('1697', 'Province of Potenza', '107'),
    ('1698', 'Metropolitan City of Milan', '107'), -- Replaces Province (Milano)
    ('1699', 'Metropolitan City of Genoa', '107'), -- Replaces Province (Genova)
    ('1700', 'Province of Prato', '107'),
    ('1701', 'Province of Benevento', '107'), -- Changed Benevento Province to Province of Benevento
    ('1702', 'Piedmont', '107'), -- Piemonte (Region)
    ('1703', 'Calabria', '107'), -- Region
    ('1704', 'Province of Bergamo', '107'),
    ('1705', 'Lombardy', '107'), -- Lombardia (Region)
    ('1706', 'Basilicata', '107'), -- Region
    ('1707', 'Province of Ravenna', '107'),
    ('1708', 'Province of Reggio Emilia', '107'),
    ('1709', 'Sicily', '107'), -- Sicilia (Autonomous Region)
    ('1710', 'Metropolitan City of Turin', '107'), -- Replaces Province (Torino)
    (
        '1711',
        'Metropolitan City of Rome Capital',
        '107'
    ), -- Changed Metropolitan City of Rome to Metropolitan City of Rome Capital (official)
    ('1712', 'Province of Rieti', '107'),
    ('1713', 'Province of Rimini', '107'),
    ('1714', 'Province of Brindisi', '107'),
    ('1715', 'Sardinia', '107'), -- Sardegna (Autonomous Region)
    ('1716', 'Aosta Valley', '107'), -- Valle d'Aosta (Autonomous Region)
    ('1717', 'Province of Brescia', '107'),
    (
        '1718',
        'Free municipal consortium of Caltanissetta',
        '107'
    ), -- Libero consorzio comunale di Caltanissetta (replaces Province)
    ('1719', 'Province of Rovigo', '107'),
    ('1720', 'Province of Salerno', '107'),
    ('1721', 'Province of Campobasso', '107'),
    ('1722', 'Province of Sassari', '107'),
    (
        '1723',
        'Free municipal consortium of Enna',
        '107'
    ), -- Libero consorzio comunale di Enna (replaces Province)
    ('1724', 'Metropolitan City of Naples', '107'), -- Replaces Province (Napoli)
    ('1725', 'Trentino-Alto Adige/Südtirol', '107'), -- Changed Trentino-South Tyrol to Trentino-Alto Adige/Südtirol (Autonomous Region), Südtirol has 'ü'
    ('1726', 'Province of Verbano-Cusio-Ossola', '107'),
    (
        '1727',
        'Free municipal consortium of Agrigento',
        '107'
    ), -- Libero consorzio comunale di Agrigento (replaces Province)
    ('1728', 'Province of Catanzaro', '107'),
    (
        '1729',
        'Free municipal consortium of Ragusa',
        '107'
    ), -- Libero consorzio comunale di Ragusa (replaces Province)
    ('1730', 'Province of South Sardinia', '107'), -- Changed Province of Carbonia-Iglesias to Province of South Sardinia (Sud Sardegna, established 2016, absorbing Carbonia-Iglesias and Medio Campidano)
    ('1731', 'Province of Caserta', '107'),
    ('1732', 'Province of Savona', '107'),
    (
        '1733',
        'Free municipal consortium of Trapani',
        '107'
    ), -- Libero consorzio comunale di Trapani (replaces Province)
    ('1734', 'Province of Siena', '107'),
    ('1735', 'Province of Viterbo', '107'),
    ('1736', 'Province of Verona', '107'),
    ('1737', 'Province of Vibo Valentia', '107'),
    ('1738', 'Province of Vicenza', '107'),
    ('1739', 'Province of Chieti', '107'),
    ('1740', 'Province of Como', '107'),
    ('1741', 'Province of Sondrio', '107'),
    ('1742', 'Province of Cosenza', '107'),
    ('1743', 'Province of Taranto', '107'),
    ('1744', 'Province of Fermo', '107'),
    ('1745', 'Province of Livorno', '107'),
    ('1746', 'Province of Ferrara', '107'),
    ('1747', 'Province of Lodi', '107'),
    ('1748', 'Autonomous Province of Trento', '107'), -- Changed Trentino to Autonomous Province of Trento (Trentino)
    ('1749', 'Province of Lucca', '107'),
    ('1750', 'Province of Macerata', '107'),
    ('1751', 'Province of Cremona', '107'),
    ('1752', 'Province of Teramo', '107'),
    ('1753', 'Veneto', '107'), -- Region
    ('1754', 'Province of Crotone', '107'),
    ('1755', 'Province of Terni', '107'),
    ('1756', 'Friuli-Venezia Giulia', '107'), -- Changed Friuli–Venezia Giulia to Friuli-Venezia Giulia (Autonomous Region), en dash to hyphen
    ('1757', 'Province of Modena', '107'),
    ('1758', 'Province of Mantua', '107'), -- Mantova
    ('1759', 'Province of Massa and Carrara', '107'),
    ('1760', 'Province of Matera', '107'),
    (
        '1761',
        'Province of Medio Campidano (historical)',
        '107'
    ), -- Abolished 2016, merged into South Sardinia, Added (historical)
    ('1762', 'Province of Treviso', '107'),
    ('1763', 'Province of Trieste (historical)', '107'), -- Abolished 2017, functions transferred, Added (historical)
    ('1764', 'Province of Udine (historical)', '107'), -- Abolished 2018, functions transferred, Added (historical)
    ('1765', 'Province of Varese', '107'),
    ('1766', 'Metropolitan City of Catania', '107'), -- Replaces Province
    (
        '1767',
        'Autonomous Province of Bolzano – South Tyrol',
        '107'
    ), -- Changed South Tyrol to Autonomous Province of Bolzano – South Tyrol (Alto Adige/Südtirol)
    ('1768', 'Liguria', '107'), -- Region
    ('1769', 'Province of Monza and Brianza', '107'),
    ('1770', 'Metropolitan City of Messina', '107'), -- Replaces Province
    ('1771', 'Province of Foggia', '107'),
    ('1772', 'Metropolitan City of Bari', '107'), -- Replaces Province
    ('1773', 'Emilia-Romagna', '107'), -- Region
    ('1774', 'Province of Novara', '107'),
    ('1775', 'Province of Cuneo', '107'),
    ('1776', 'Province of Frosinone', '107'),
    ('1777', 'Province of Gorizia (historical)', '107'), -- Abolished 2017, functions transferred, Added (historical)
    ('1778', 'Province of Biella', '107'),
    ('1779', 'Province of Forlì-Cesena', '107'), -- Forlì has 'ì'
    ('1780', 'Province of Asti', '107'),
    ('1781', 'Province of L''Aquila', '107'), -- Fixed escaping
    (
        '1782',
        'Province of Ogliastra (historical)',
        '107'
    ), -- Abolished 2016, merged into Nuoro/South Sardinia, Added (historical)
    ('1783', 'Province of Alessandria', '107'),
    (
        '1784',
        'Province of Olbia-Tempio (historical)',
        '107'
    ), -- Abolished 2016, merged into Sassari, Added (historical)
    ('1785', 'Province of Vercelli', '107'),
    ('1786', 'Province of Oristano', '107'),
    ('1787', 'Province of Grosseto', '107'),
    ('1788', 'Province of Imperia', '107'),
    ('1789', 'Province of Isernia', '107'),
    ('1790', 'Province of Nuoro', '107'),
    ('1791', 'Province of La Spezia', '107'),
    ('1792', 'North Sumatra', '102'), -- Province
    ('1793', 'Bengkulu', '102'), -- Province
    ('1794', 'Central Kalimantan', '102'), -- Province
    ('1795', 'South Sulawesi', '102'), -- Province
    ('1796', 'Southeast Sulawesi', '102'), -- Province
    ('1797', 'Sumatra', '102'), -- Island (Geographical region, not administrative) - Consider removing or clarifying
    ('1798', 'Papua', '102'), -- Province (Note: Large parts split off into new provinces in 2022)
    ('1799', 'West Papua', '102'), -- Province (Papua Barat) (Note: Southwest Papua split off in 2022)
    ('1800', 'Maluku', '102'), -- Province
    ('1801', 'North Maluku', '102'), -- Province
    ('1802', 'Central Java', '102'), -- Province
    ('1803', 'Sulawesi', '102'), -- Island (Geographical region, not administrative) - Consider removing or clarifying
    ('1804', 'East Kalimantan', '102'), -- Province
    ('1805', 'Jakarta Special Capital Region', '102'), -- Changed Jakarta to Jakarta Special Capital Region (DKI Jakarta)
    ('1806', 'Kalimantan', '102'), -- Island (Geographical region, not administrative) - Consider removing or clarifying
    ('1807', 'Riau Islands', '102'), -- Province
    ('1808', 'North Sulawesi', '102'), -- Province
    ('1809', 'Riau', '102'), -- Province
    ('1810', 'Banten', '102'), -- Province
    ('1811', 'Lampung', '102'), -- Province
    ('1812', 'Gorontalo', '102'), -- Province
    ('1813', 'Central Sulawesi', '102'), -- Province
    ('1814', 'West Nusa Tenggara', '102'), -- Province
    ('1815', 'Jambi', '102'), -- Province
    ('1816', 'South Sumatra', '102'), -- Province
    ('1817', 'West Sulawesi', '102'), -- Province
    ('1818', 'East Nusa Tenggara', '102'), -- Province
    ('1819', 'South Kalimantan', '102'), -- Province
    ('1820', 'Bangka Belitung Islands', '102'), -- Province
    ('1821', 'Nusa Tenggara', '102'), -- Changed Lesser Sunda Islands to Nusa Tenggara (Geographical region) - Consider removing or clarifying
    ('1822', 'Aceh', '102'), -- Special Region (Province)
    ('1823', 'Maluku Islands', '102'), -- Archipelago (Geographical region, not administrative) - Consider removing or clarifying
    ('1824', 'North Kalimantan', '102'), -- Province
    ('1825', 'West Java', '102'), -- Province
    ('1826', 'Bali', '102'), -- Province
    ('1827', 'East Java', '102'), -- Province
    ('1828', 'West Sumatra', '102'), -- Province
    ('1829', 'Special Region of Yogyakarta', '102'), -- Province-level Special Region
    ('1830', 'Phoenix Islands', '114'), -- Part of Kiribati, mostly uninhabited
    ('1831', 'Gilbert Islands', '114'), -- Main island group of Kiribati
    ('1832', 'Line Islands', '114'), -- Island group of Kiribati
    ('1833', 'Primorsky Krai', '182'),
    ('1834', 'Novgorod Oblast', '182'),
    ('1835', 'Jewish Autonomous Oblast', '182'),
    ('1836', 'Nenets Autonomous Okrug', '182'),
    ('1837', 'Rostov Oblast', '182'),
    ('1838', 'Khanty-Mansi Autonomous Okrug', '182'),
    ('1839', 'Magadan Oblast', '182'),
    ('1840', 'Krasnoyarsk Krai', '182'),
    ('1841', 'Republic of Karelia', '182'),
    ('1842', 'Republic of Buryatia', '182'),
    ('1843', 'Murmansk Oblast', '182'),
    ('1844', 'Kaluga Oblast', '182'),
    ('1845', 'Chelyabinsk Oblast', '182'),
    ('1846', 'Omsk Oblast', '182'),
    ('1847', 'Yamalo-Nenets Autonomous Okrug', '182'),
    ('1848', 'Sakha (Yakutia) Republic', '182'), -- Changed Sakha Republic to Sakha (Yakutia) Republic
    ('1849', 'Arkhangelsk Oblast', '182'), -- Changed Arkhangelsk to Arkhangelsk Oblast
    ('1850', 'Republic of Dagestan', '182'),
    ('1851', 'Yaroslavl Oblast', '182'),
    ('1852', 'Republic of Adygea', '182'),
    ('1853', 'Republic of North Ossetia–Alania', '182'), -- Added en dash
    ('1854', 'Republic of Bashkortostan', '182'),
    ('1855', 'Kursk Oblast', '182'),
    ('1856', 'Ulyanovsk Oblast', '182'),
    ('1857', 'Nizhny Novgorod Oblast', '182'),
    ('1858', 'Amur Oblast', '182'),
    ('1859', 'Chukotka Autonomous Okrug', '182'),
    ('1860', 'Tver Oblast', '182'),
    ('1861', 'Republic of Tatarstan', '182'),
    ('1862', 'Samara Oblast', '182'),
    ('1863', 'Pskov Oblast', '182'),
    ('1864', 'Ivanovo Oblast', '182'),
    ('1865', 'Kamchatka Krai', '182'),
    ('1866', 'Astrakhan Oblast', '182'),
    ('1867', 'Bryansk Oblast', '182'),
    ('1868', 'Stavropol Krai', '182'),
    ('1869', 'Karachay-Cherkess Republic', '182'),
    ('1870', 'Mari El Republic', '182'),
    ('1871', 'Perm Krai', '182'),
    ('1872', 'Tomsk Oblast', '182'),
    ('1873', 'Khabarovsk Krai', '182'),
    ('1874', 'Vologda Oblast', '182'),
    ('1875', 'Sakhalin Oblast', '182'), -- Changed Sakhalin to Sakhalin Oblast
    ('1876', 'Altai Republic', '182'),
    ('1877', 'Republic of Khakassia', '182'),
    ('1878', 'Tambov Oblast', '182'),
    ('1879', 'Saint Petersburg', '182'), -- Federal City
    ('1880', 'Irkutsk Oblast', '182'), -- Changed Irkutsk to Irkutsk Oblast
    ('1881', 'Vladimir Oblast', '182'),
    ('1882', 'Moscow Oblast', '182'),
    ('1883', 'Republic of Kalmykia', '182'),
    ('1884', 'Republic of Ingushetia', '182'),
    ('1885', 'Smolensk Oblast', '182'),
    ('1886', 'Orenburg Oblast', '182'),
    ('1887', 'Saratov Oblast', '182'),
    ('1888', 'Novosibirsk Oblast', '182'), -- Changed Novosibirsk to Novosibirsk Oblast
    ('1889', 'Lipetsk Oblast', '182'),
    ('1890', 'Kirov Oblast', '182'),
    ('1891', 'Krasnodar Krai', '182'),
    ('1892', 'Kabardino-Balkar Republic', '182'),
    ('1893', 'Chechen Republic', '182'),
    ('1894', 'Sverdlovsk Oblast', '182'), -- Changed Sverdlovsk to Sverdlovsk Oblast
    ('1895', 'Tula Oblast', '182'),
    ('1896', 'Leningrad Oblast', '182'),
    ('1897', 'Kemerovo Oblast - Kuzbass', '182'), -- Changed Kemerovo Oblast to Kemerovo Oblast - Kuzbass (official name change 2019)
    ('1898', 'Republic of Mordovia', '182'),
    ('1899', 'Komi Republic', '182'),
    ('1900', 'Tuva Republic', '182'),
    ('1901', 'Moscow', '182'), -- Federal City
    ('1902', 'Kaliningrad Oblast', '182'), -- Changed Kaliningrad to Kaliningrad Oblast
    ('1903', 'Belgorod Oblast', '182'),
    ('1904', 'Zabaykalsky Krai', '182'),
    ('1905', 'Ryazan Oblast', '182'),
    ('1906', 'Voronezh Oblast', '182'),
    ('1907', 'Tyumen Oblast', '182'),
    ('1908', 'Oryol Oblast', '182'),
    ('1909', 'Penza Oblast', '182'),
    ('1910', 'Kostroma Oblast', '182'),
    ('1911', 'Altai Krai', '182'),
    ('1912', 'Sevastopol', '182'), -- Federal City (Disputed / Annexed)
    ('1913', 'Udmurt Republic', '182'),
    ('1914', 'Chuvash Republic', '182'),
    ('1915', 'Kurgan Oblast', '182'),
    ('1916', 'Lomaiviti Province', '73'), -- Changed Lomaiviti to Lomaiviti Province
    ('1917', 'Ba Province', '73'), -- Changed Ba to Ba Province
    ('1918', 'Tailevu Province', '73'), -- Changed Tailevu to Tailevu Province
    ('1919', 'Nadroga-Navosa Province', '73'), -- Changed Nadroga-Navosa to Nadroga-Navosa Province
    ('1920', 'Rewa Province', '73'), -- Changed Rewa to Rewa Province
    ('1921', 'Northern Division', '73'),
    ('1922', 'Macuata Province', '73'), -- Changed Macuata to Macuata Province
    ('1923', 'Western Division', '73'),
    ('1924', 'Cakaudrove Province', '73'), -- Changed Cakaudrove to Cakaudrove Province
    ('1925', 'Serua Province', '73'), -- Changed Serua to Serua Province
    ('1926', 'Ra Province', '73'), -- Changed Ra to Ra Province
    ('1927', 'Naitasiri Province', '73'), -- Changed Naitasiri to Naitasiri Province
    ('1928', 'Namosi Province', '73'), -- Changed Namosi to Namosi Province
    ('1929', 'Central Division', '73'),
    ('1930', 'Bua Province', '73'), -- Changed Bua to Bua Province
    ('1931', 'Rotuma', '73'), -- Dependency
    ('1932', 'Eastern Division', '73'),
    ('1933', 'Lau Province', '73'), -- Changed Lau to Lau Province
    ('1934', 'Kadavu Province', '73'), -- Changed Kadavu to Kadavu Province
    ('1935', 'Labuan', '132'), -- Federal Territory
    ('1936', 'Sabah', '132'), -- State
    ('1937', 'Sarawak', '132'), -- State
    ('1938', 'Perlis', '132'), -- State
    ('1939', 'Penang', '132'), -- State (Pulau Pinang)
    ('1940', 'Pahang', '132'), -- State
    ('1941', 'Melaka', '132'), -- State (Malacca)
    ('1942', 'Terengganu', '132'), -- State
    ('1943', 'Perak', '132'), -- State
    ('1944', 'Selangor', '132'), -- State
    ('1945', 'Putrajaya', '132'), -- Federal Territory
    ('1946', 'Kelantan', '132'), -- State
    ('1947', 'Kedah', '132'), -- State
    ('1948', 'Negeri Sembilan', '132'), -- State
    ('1949', 'Kuala Lumpur', '132'), -- Federal Territory
    ('1950', 'Johor', '132'), -- State
    ('1951', 'Mashonaland East Province', '247'),
    ('1952', 'Matabeleland South Province', '247'),
    ('1953', 'Mashonaland West Province', '247'),
    ('1954', 'Matabeleland North Province', '247'),
    ('1955', 'Mashonaland Central Province', '247'),
    ('1956', 'Bulawayo Province', '247'), -- Metropolitan Province
    ('1957', 'Midlands Province', '247'),
    ('1958', 'Harare Province', '247'), -- Metropolitan Province
    ('1959', 'Manicaland Province', '247'), -- Changed Manicaland to Manicaland Province
    ('1960', 'Masvingo Province', '247'),
    ('1961', 'Bulgan Province', '146'), -- Aimag
    ('1962', 'Darkhan-Uul Province', '146'), -- Aimag
    ('1963', 'Dornod Province', '146'), -- Aimag
    ('1964', 'Khovd Province', '146'), -- Aimag
    ('1965', 'Övörkhangai Province', '146'), -- Övörkhangai has 'Ö', 'ö' (Aimag)
    ('1966', 'Orkhon Province', '146'), -- Aimag
    ('1967', 'Ömnögovi Province', '146'), -- Ömnögovi has 'Ö', 'ö' (Aimag - Southgobi)
    ('1968', 'Töv Province', '146'), -- Töv has 'ö' (Aimag - Central)
    ('1969', 'Bayan-Ölgii Province', '146'), -- Ölgii has 'Ö' (Aimag)
    ('1970', 'Dundgovi Province', '146'), -- Aimag (Middle Gobi)
    ('1971', 'Uvs Province', '146'), -- Aimag
    ('1972', 'Govi-Altai Province', '146'), -- Aimag
    ('1973', 'Arkhangai Province', '146'), -- Aimag
    ('1974', 'Khentii Province', '146'), -- Aimag
    ('1975', 'Khövsgöl Province', '146'), -- Khövsgöl has 'ö' (Aimag)
    ('1976', 'Bayankhongor Province', '146'), -- Aimag
    ('1977', 'Sükhbaatar Province', '146'), -- Sükhbaatar has 'ü' (Aimag)
    ('1978', 'Govisümber Province', '146'), -- Govisümber has 'ü' (Aimag)
    ('1979', 'Zavkhan Province', '146'), -- Aimag
    ('1980', 'Selenge Province', '146'), -- Aimag
    ('1981', 'Dornogovi Province', '146'), -- Aimag (East Gobi)
    ('1982', 'Northern Province', '246'),
    ('1983', 'Western Province', '246'),
    ('1984', 'Copperbelt Province', '246'),
    ('1985', 'Northwestern Province', '246'), -- North-Western Province
    ('1986', 'Central Province', '246'),
    ('1987', 'Luapula Province', '246'),
    ('1988', 'Lusaka Province', '246'),
    ('1989', 'Muchinga Province', '246'),
    ('1990', 'Southern Province', '246'),
    ('1991', 'Eastern Province', '246'),
    ('1992', 'Capital Governorate', '18'),
    ('1993', 'Southern Governorate', '18'),
    ('1994', 'Northern Governorate', '18'),
    ('1995', 'Muharraq Governorate', '18'),
    ('1996', 'Central Governorate (historical)', '18'), -- Abolished 2014, territory split. Added (historical).
    ('1997', 'Rio de Janeiro', '31'), -- State
    ('1998', 'Minas Gerais', '31'), -- State
    ('1999', 'Amapá', '31'), -- State (Amapá has 'á')
    ('2000', 'Goiás', '31'), -- State (Goiás has 'á')
    ('2001', 'Rio Grande do Sul', '31'), -- State
    ('2002', 'Bahia', '31'), -- State
    ('2003', 'Sergipe', '31'), -- State
    ('2004', 'Amazonas', '31'), -- State
    ('2005', 'Paraíba', '31'), -- State (Paraíba has 'í')
    ('2006', 'Pernambuco', '31'), -- State
    ('2007', 'Alagoas', '31'), -- State
    ('2008', 'Piauí', '31'), -- State (Piauí has 'í')
    ('2009', 'Pará', '31'), -- State (Pará has 'á')
    ('2010', 'Mato Grosso do Sul', '31'), -- State
    ('2011', 'Mato Grosso', '31'), -- State
    ('2012', 'Acre', '31'), -- State
    ('2013', 'Rondônia', '31'), -- State (Rondônia has 'ô')
    ('2014', 'Santa Catarina', '31'), -- State
    ('2015', 'Maranhão', '31'), -- State (Maranhão has 'ã')
    ('2016', 'Ceará', '31'), -- State (Ceará has 'á')
    ('2017', 'Federal District', '31'), -- Distrito Federal
    ('2018', 'Espírito Santo', '31'), -- State (Espírito has 'í')
    ('2019', 'Rio Grande do Norte', '31'), -- State
    ('2020', 'Tocantins', '31'), -- State
    ('2021', 'São Paulo', '31'), -- State (São Paulo has 'ã')
    ('2022', 'Paraná', '31'), -- State (Paraná has 'á')
    ('2023', 'Aragatsotn Region', '12'), -- Marz
    ('2024', 'Ararat Province', '12'), -- Marz
    ('2025', 'Vayots Dzor Region', '12'), -- Marz
    ('2026', 'Armavir Region', '12'), -- Marz
    ('2027', 'Syunik Province', '12'), -- Marz
    ('2028', 'Gegharkunik Province', '12'), -- Marz
    ('2029', 'Lori Region', '12'), -- Marz
    ('2030', 'Yerevan', '12'), -- City / Marz
    ('2031', 'Shirak Region', '12'), -- Marz
    ('2032', 'Tavush Region', '12'), -- Marz
    ('2033', 'Kotayk Region', '12'), -- Marz
    ('2034', 'Cojedes', '239'), -- State
    ('2035', 'Falcón', '239'), -- State (Falcón has 'ó')
    ('2036', 'Portuguesa', '239'), -- State
    ('2037', 'Miranda', '239'), -- State
    ('2038', 'Lara', '239'), -- State
    ('2039', 'Bolívar', '239'), -- State (Bolívar has 'í')
    ('2040', 'Carabobo', '239'), -- State
    ('2041', 'Yaracuy', '239'), -- State
    ('2042', 'Zulia', '239'), -- State
    ('2043', 'Trujillo', '239'), -- State
    ('2044', 'Amazonas', '239'), -- State
    ('2045', 'Guárico', '239'), -- State (Guárico has 'á')
    (
        '2046',
        'Federal Dependencies of Venezuela',
        '239'
    ),
    ('2047', 'Aragua', '239'), -- State
    ('2048', 'Táchira', '239'), -- State (Táchira has 'á')
    ('2049', 'Barinas', '239'), -- State
    ('2050', 'Anzoátegui', '239'), -- State (Anzoátegui has 'á')
    ('2051', 'Delta Amacuro', '239'), -- State
    ('2052', 'Nueva Esparta', '239'), -- State
    ('2053', 'Mérida', '239'), -- State (Mérida has 'é')
    ('2054', 'Monagas', '239'), -- State
    ('2055', 'La Guaira', '239'), -- Changed Vargas to La Guaira (official name change 2019)
    ('2056', 'Sucre', '239'), -- State
    ('2057', 'Carinthia', '15'), -- Kärnten (State)
    ('2058', 'Upper Austria', '15'), -- Oberösterreich (State)
    ('2059', 'Styria', '15'), -- Steiermark (State)
    ('2060', 'Vienna', '15'), -- Wien (State/Capital)
    ('2061', 'Salzburg', '15'), -- State
    ('2062', 'Burgenland', '15'), -- State
    ('2063', 'Vorarlberg', '15'), -- State
    ('2064', 'Tyrol', '15'), -- Tirol (State)
    ('2065', 'Lower Austria', '15'), -- Niederösterreich (State)
    ('2066', 'Karnali Province', '154'), -- Changed Mid-Western Region to Karnali Province (new structure 2015)
    ('2067', 'Gandaki Province', '154'), -- Changed Western Region to Gandaki Province (new structure 2015)
    ('2068', 'Sudurpashchim Province', '154'), -- Changed Far-Western Development Region to Sudurpashchim Province (new structure 2015)
    ('2069', 'Province No. 1', '154'), -- Changed Eastern Development Region to Province No. 1 (new structure 2015, name likely temporary)
    ('2070', 'Mechi Zone (historical)', '154'), -- Zone abolished 2015, Added (historical)
    ('2071', 'Bheri Zone (historical)', '154'), -- Zone abolished 2015, Added (historical)
    ('2072', 'Kosi Zone (historical)', '154'), -- Zone abolished 2015, Added (historical)
    ('2073', 'Bagmati Province', '154'), -- Changed Central Region to Bagmati Province (new structure 2015)
    ('2074', 'Lumbini Zone (historical)', '154'), -- Zone abolished 2015, Added (historical)
    ('2075', 'Narayani Zone (historical)', '154'), -- Zone abolished 2015, Added (historical)
    ('2076', 'Janakpur Zone (historical)', '154'), -- Zone abolished 2015, Added (historical)
    ('2077', 'Rapti Zone (historical)', '154'), -- Zone abolished 2015, Added (historical)
    ('2078', 'Seti Zone (historical)', '154'), -- Zone abolished 2015, Added (historical)
    ('2079', 'Karnali Zone (historical)', '154'), -- Zone abolished 2015, Added (historical)
    ('2080', 'Dhaulagiri Zone (historical)', '154'), -- Zone abolished 2015, Added (historical)
    ('2081', 'Gandaki Zone (historical)', '154'), -- Zone abolished 2015, Added (historical)
    ('2082', 'Bagmati Zone (historical)', '154'), -- Zone abolished 2015, Added (historical)
    ('2083', 'Mahakali Zone (historical)', '154'), -- Zone abolished 2015, Added (historical)
    ('2084', 'Sagarmatha Zone (historical)', '154'), -- Zone abolished 2015, Added (historical)
    ('2085', 'Unity State', '206'), -- State (Note: South Sudan states reorganized multiple times, this reflects 10-state structure)
    ('2086', 'Upper Nile State', '206'), -- State
    ('2087', 'Warrap State', '206'), -- State
    ('2088', 'Northern Bahr el Ghazal State', '206'), -- State
    ('2089', 'Western Equatoria State', '206'), -- State
    ('2090', 'Lakes State', '206'), -- State
    ('2091', 'Western Bahr el Ghazal State', '206'), -- State
    ('2092', 'Central Equatoria State', '206'), -- State
    ('2093', 'Eastern Equatoria State', '206'), -- State
    ('2094', 'Jonglei State', '206'), -- State
    ('2095', 'Karditsa Regional Unit', '85'),
    ('2096', 'West Greece Region', '85'),
    ('2097', 'Thessaloniki Regional Unit', '85'),
    ('2098', 'Arcadia Regional Unit', '85'), -- Changed Arcadia Prefecture to Arcadia Regional Unit
    ('2099', 'Imathia Regional Unit', '85'),
    ('2100', 'Kastoria Regional Unit', '85'),
    ('2101', 'Euboea Regional Unit', '85'), -- Changed Euboea to Euboea Regional Unit
    ('2102', 'Grevena Regional Unit', '85'), -- Changed Grevena Prefecture to Grevena Regional Unit
    ('2103', 'Preveza Regional Unit', '85'), -- Changed Preveza Prefecture to Preveza Regional Unit
    ('2104', 'Lefkada Regional Unit', '85'),
    ('2105', 'Argolis Regional Unit', '85'),
    ('2106', 'Laconia Regional Unit', '85'), -- Changed Laconia to Laconia Regional Unit
    ('2107', 'Pella Regional Unit', '85'),
    ('2108', 'West Macedonia Region', '85'),
    ('2109', 'Crete Region', '85'),
    ('2110', 'Epirus Region', '85'),
    ('2111', 'Kilkis Regional Unit', '85'),
    ('2112', 'Kozani Regional Unit', '85'), -- Changed Kozani Prefecture to Kozani Regional Unit
    ('2113', 'Ioannina Regional Unit', '85'),
    ('2114', 'Phthiotis Regional Unit', '85'), -- Changed Phthiotis Prefecture to Phthiotis Regional Unit
    ('2115', 'Chania Regional Unit', '85'),
    ('2116', 'Achaea Regional Unit', '85'),
    ('2117', 'East Macedonia and Thrace Region', '85'), -- Changed East Macedonia and Thrace to East Macedonia and Thrace Region
    ('2118', 'South Aegean Region', '85'), -- Changed South Aegean to South Aegean Region
    ('2119', 'Peloponnese Region', '85'),
    ('2120', 'East Attica Regional Unit', '85'),
    ('2121', 'Serres Regional Unit', '85'), -- Changed Serres Prefecture to Serres Regional Unit
    ('2122', 'Attica Region', '85'),
    ('2123', 'Aetolia-Acarnania Regional Unit', '85'),
    ('2124', 'Corfu Regional Unit', '85'), -- Changed Corfu Prefecture to Corfu Regional Unit
    ('2125', 'Central Macedonia Region', '85'), -- Changed Central Macedonia to Central Macedonia Region
    ('2126', 'Boeotia Regional Unit', '85'),
    ('2127', 'Kefalonia Regional Unit', '85'), -- Changed Kefalonia Prefecture to Kefalonia Regional Unit
    ('2128', 'Central Greece Region', '85'),
    ('2129', 'Corinthia Regional Unit', '85'),
    ('2130', 'Drama Regional Unit', '85'),
    ('2131', 'Ionian Islands Region', '85'),
    ('2132', 'Larissa Regional Unit', '85'), -- Changed Larissa Prefecture to Larissa Regional Unit
    ('2133', 'Kayin State', '151'), -- State/Region
    ('2134', 'Mandalay Region', '151'), -- Region
    ('2135', 'Yangon Region', '151'), -- Region
    ('2136', 'Magway Region', '151'), -- Region
    ('2137', 'Chin State', '151'), -- State
    ('2138', 'Rakhine State', '151'), -- State
    ('2139', 'Shan State', '151'), -- State
    ('2140', 'Tanintharyi Region', '151'), -- Region
    ('2141', 'Bago Region', '151'), -- Changed Bago to Bago Region
    ('2142', 'Ayeyarwady Region', '151'), -- Region
    ('2143', 'Kachin State', '151'), -- State
    ('2144', 'Kayah State', '151'), -- State
    ('2145', 'Sagaing Region', '151'), -- Region
    ('2146', 'Naypyidaw Union Territory', '151'),
    ('2147', 'Mon State', '151'), -- State
    ('2148', 'Bartın Province', '225'), -- Bartın has 'ı'
    ('2149', 'Kütahya Province', '225'),
    ('2150', 'Sakarya Province', '225'),
    ('2151', 'Edirne Province', '225'),
    ('2152', 'Van Province', '225'),
    ('2153', 'Bingöl Province', '225'),
    ('2154', 'Kilis Province', '225'),
    ('2155', 'Adıyaman Province', '225'), -- Adıyaman has 'ı'
    ('2156', 'Mersin Province', '225'), -- (Formerly İçel)
    ('2157', 'Denizli Province', '225'),
    ('2158', 'Malatya Province', '225'),
    ('2159', 'Elazığ Province', '225'), -- Elazığ has 'ğ'
    ('2160', 'Erzincan Province', '225'),
    ('2161', 'Amasya Province', '225'),
    ('2162', 'Muş Province', '225'), -- Muş has 'ş'
    ('2163', 'Bursa Province', '225'),
    ('2164', 'Eskişehir Province', '225'), -- Eskişehir has 'ş'
    ('2165', 'Erzurum Province', '225'),
    ('2166', 'Iğdır Province', '225'), -- Iğdır has 'I', 'ı'
    ('2167', 'Tekirdağ Province', '225'), -- Tekirdağ has 'ğ'
    ('2168', 'Çankırı Province', '225'), -- Çankırı has 'Ç', 'ı'
    ('2169', 'Antalya Province', '225'),
    ('2170', 'Istanbul Province', '225'), -- İstanbul has 'İ'
    ('2171', 'Konya Province', '225'),
    ('2172', 'Bolu Province', '225'),
    ('2173', 'Çorum Province', '225'), -- Çorum has 'Ç'
    ('2174', 'Ordu Province', '225'),
    ('2175', 'Balıkesir Province', '225'), -- Balıkesir has 'ı'
    ('2176', 'Kırklareli Province', '225'), -- Kırklareli has 'ı'
    ('2177', 'Bayburt Province', '225'),
    ('2178', 'Kırıkkale Province', '225'), -- Kırıkkale has 'ı'
    ('2179', 'Afyonkarahisar Province', '225'),
    ('2180', 'Kırşehir Province', '225'), -- Kırşehir has 'ı', 'ş'
    ('2181', 'Sivas Province', '225'),
    ('2182', 'Muğla Province', '225'), -- Muğla has 'ğ'
    ('2183', 'Şanlıurfa Province', '225'), -- Şanlıurfa has 'Ş', 'ş'
    ('2184', 'Karaman Province', '225'),
    ('2185', 'Ardahan Province', '225'),
    ('2186', 'Giresun Province', '225'),
    ('2187', 'Aydın Province', '225'), -- Aydın has 'ı'
    ('2188', 'Yozgat Province', '225'),
    ('2189', 'Niğde Province', '225'), -- Niğde has 'ğ'
    ('2190', 'Hakkâri Province', '225'), -- Hakkâri has 'â'
    ('2191', 'Artvin Province', '225'),
    ('2192', 'Tunceli Province', '225'),
    ('2193', 'Ağrı Province', '225'), -- Ağrı has 'ğ', 'ı'
    ('2194', 'Batman Province', '225'),
    ('2195', 'Kocaeli Province', '225'),
    ('2196', 'Nevşehir Province', '225'), -- Nevşehir has 'ş'
    ('2197', 'Kastamonu Province', '225'),
    ('2198', 'Manisa Province', '225'),
    ('2199', 'Tokat Province', '225'),
    ('2200', 'Kayseri Province', '225'),
    ('2201', 'Uşak Province', '225'), -- Uşak has 'ş'
    ('2202', 'Düzce Province', '225'),
    ('2203', 'Gaziantep Province', '225'),
    ('2204', 'Gümüşhane Province', '225'), -- Gümüşhane has 'ü', 'ş'
    ('2205', 'İzmir Province', '225'), -- İzmir has 'İ', 'ı'
    ('2206', 'Trabzon Province', '225'),
    ('2207', 'Siirt Province', '225'),
    ('2208', 'Kars Province', '225'),
    ('2209', 'Burdur Province', '225'),
    ('2210', 'Aksaray Province', '225'),
    ('2211', 'Hatay Province', '225'),
    ('2212', 'Adana Province', '225'),
    ('2213', 'Zonguldak Province', '225'),
    ('2214', 'Osmaniye Province', '225'),
    ('2215', 'Bitlis Province', '225'),
    ('2216', 'Çanakkale Province', '225'), -- Çanakkale has 'Ç'
    ('2217', 'Ankara Province', '225'),
    ('2218', 'Yalova Province', '225'),
    ('2219', 'Rize Province', '225'),
    ('2220', 'Samsun Province', '225'),
    ('2221', 'Bilecik Province', '225'),
    ('2222', 'Isparta Province', '225'), -- Isparta has 'I'
    ('2223', 'Karabük Province', '225'),
    ('2224', 'Mardin Province', '225'),
    ('2225', 'Şırnak Province', '225'), -- Şırnak has 'Ş', 'ı'
    ('2226', 'Diyarbakır Province', '225'), -- Diyarbakır has 'ı'
    ('2227', 'Kahramanmaraş Province', '225'), -- Kahramanmaraş has 'ş'
    ('2228', 'Lisbon District', '177'),
    ('2229', 'Bragança District', '177'), -- Bragança has 'ç'
    ('2230', 'Beja District', '177'),
    ('2231', 'Madeira', '177'), -- Autonomous Region
    ('2232', 'Portalegre District', '177'),
    ('2233', 'Azores', '177'), -- Autonomous Region (Açores)
    ('2234', 'Vila Real District', '177'),
    ('2235', 'Aveiro District', '177'),
    ('2236', 'Évora District', '177'), -- Évora has 'É'
    ('2237', 'Viseu District', '177'),
    ('2238', 'Santarém District', '177'), -- Santarém has 'é'
    ('2239', 'Faro District', '177'),
    ('2240', 'Leiria District', '177'),
    ('2241', 'Castelo Branco District', '177'),
    ('2242', 'Setúbal District', '177'), -- Setúbal has 'ú'
    ('2243', 'Porto District', '177'), -- (Oporto)
    ('2244', 'Braga District', '177'),
    ('2245', 'Viana do Castelo District', '177'),
    ('2246', 'Coimbra District', '177'),
    ('2247', 'Zhejiang', '45'), -- Province
    ('2248', 'Fujian', '45'), -- Province
    ('2249', 'Shanghai', '45'), -- Municipality
    ('2250', 'Jiangsu', '45'), -- Province
    ('2251', 'Anhui', '45'), -- Province
    ('2252', 'Shandong', '45'), -- Province
    ('2253', 'Jilin', '45'), -- Province
    ('2254', 'Shanxi', '45'), -- Province (山西)
    ('2255', 'Taiwan Province', '45'), -- Changed Taiwan Province, People's Republic of China to Taiwan Province (PRC claims; administered by ROC, see ID 216)
    ('2256', 'Jiangxi', '45'), -- Province
    ('2257', 'Beijing', '45'), -- Municipality
    ('2258', 'Hunan', '45'), -- Province
    ('2259', 'Henan', '45'), -- Province
    ('2260', 'Yunnan', '45'), -- Province
    ('2261', 'Guizhou', '45'), -- Province
    ('2262', 'Ningxia Hui Autonomous Region', '45'), -- Autonomous Region
    ('2263', 'Xinjiang Uyghur Autonomous Region', '45'), -- Changed Xinjiang to Xinjiang Uyghur Autonomous Region
    ('2264', 'Tibet Autonomous Region', '45'), -- Xizang Autonomous Region
    ('2265', 'Heilongjiang', '45'), -- Province
    ('2266', 'Macau SAR', '45'), -- Changed Macau to Macau SAR (Special Administrative Region)
    ('2267', 'Hong Kong SAR', '45'), -- Changed Hong Kong to Hong Kong SAR (Special Administrative Region)
    ('2268', 'Liaoning', '45'), -- Province
    ('2269', 'Inner Mongolia Autonomous Region', '45'), -- Changed Inner Mongolia to Inner Mongolia Autonomous Region (Nei Mongol)
    ('2270', 'Qinghai', '45'), -- Province
    ('2271', 'Chongqing', '45'), -- Municipality
    ('2272', 'Shaanxi', '45'), -- Province (陕西)
    ('2273', 'Hainan', '45'), -- Province
    ('2274', 'Hubei', '45'), -- Province
    ('2275', 'Gansu', '45'), -- Province
    ('2276', 'Keelung (Taiwan)', '45'), -- City in Taiwan (ROC), listed under China (PRC) ID. Consider moving or removing. Added (Taiwan).
    ('2277', 'Sichuan', '45'), -- Province
    ('2278', 'Guangxi Zhuang Autonomous Region', '45'), -- Autonomous Region
    ('2279', 'Guangdong', '45'), -- Province
    ('2280', 'Hebei', '45'), -- Province
    ('2281', 'South Governorate', '121'), -- Mohafazah
    ('2282', 'Mount Lebanon Governorate', '121'), -- Mohafazah
    ('2283', 'Baalbek-Hermel Governorate', '121'), -- Mohafazah
    ('2284', 'North Governorate', '121'), -- Mohafazah
    ('2285', 'Akkar Governorate', '121'), -- Mohafazah
    ('2286', 'Beirut Governorate', '121'), -- Mohafazah
    ('2287', 'Beqaa Governorate', '121'), -- Mohafazah (Bekaa)
    ('2288', 'Nabatieh Governorate', '121'), -- Mohafazah
    ('2289', 'Isle of Wight', '232'), -- County / Unitary Authority (England)
    ('2290', 'St Helens', '232'), -- Metropolitan Borough (England)
    ('2291', 'London Borough of Brent', '232'), -- Borough (England)
    ('2292', 'Walsall', '232'), -- Metropolitan Borough (England)
    ('2293', 'Trafford', '232'), -- Metropolitan Borough (England)
    ('2294', 'City of Southampton', '232'), -- Unitary Authority (England)
    ('2295', 'Sheffield', '232'), -- Metropolitan Borough (England)
    ('2296', 'West Sussex', '232'), -- County (England)
    ('2297', 'City of Peterborough', '232'), -- Unitary Authority (England)
    ('2298', 'Caerphilly County Borough', '232'), -- Principal Area (Wales)
    ('2299', 'Vale of Glamorgan', '232'), -- Principal Area (Wales)
    ('2300', 'Shetland Islands', '232'), -- Council Area (Scotland)
    ('2301', 'Rhondda Cynon Taf', '232'), -- Principal Area (Wales)
    ('2302', 'Poole (historical)', '232'), -- Unitary Authority (England), merged into Bournemouth, Christchurch and Poole in 2019. Added (historical).
    ('2303', 'Central Bedfordshire', '232'), -- Unitary Authority (England)
    (
        '2304',
        'Down District Council (historical)',
        '232'
    ), -- District (Northern Ireland), replaced by Newry, Mourne and Down in 2015. Added (historical).
    ('2305', 'City of Portsmouth', '232'), -- Unitary Authority (England)
    ('2306', 'London Borough of Haringey', '232'), -- Borough (England)
    ('2307', 'London Borough of Bexley', '232'), -- Borough (England)
    ('2308', 'Rotherham', '232'), -- Metropolitan Borough (England)
    ('2309', 'Hartlepool', '232'), -- Unitary Authority (England)
    ('2310', 'Telford and Wrekin', '232'), -- Unitary Authority (England)
    ('2311', 'Belfast', '232'), -- Changed Belfast district to Belfast (City / District - Northern Ireland)
    ('2312', 'Cornwall', '232'), -- Unitary Authority (England)
    ('2313', 'London Borough of Sutton', '232'), -- Borough (England)
    (
        '2314',
        'Omagh District Council (historical)',
        '232'
    ), -- District (Northern Ireland), replaced by Fermanagh and Omagh in 2015. Added (historical).
    ('2315', 'Banbridge (historical)', '232'), -- District Council (Northern Ireland), replaced by Armagh, Banbridge and Craigavon in 2015. Added (historical).
    ('2316', 'Causeway Coast and Glens', '232'), -- District (Northern Ireland)
    (
        '2317',
        'Newtownabbey Borough Council (historical)',
        '232'
    ), -- Borough (Northern Ireland), replaced by Antrim and Newtownabbey in 2015. Added (historical).
    ('2318', 'City of Leicester', '232'), -- Unitary Authority (England)
    ('2319', 'London Borough of Islington', '232'), -- Borough (England)
    ('2320', 'Wigan', '232'), -- Changed Metropolitan Borough of Wigan to Wigan (Metropolitan Borough - England)
    ('2321', 'Oxfordshire', '232'), -- County (England)
    (
        '2322',
        'Magherafelt District Council (historical)',
        '232'
    ), -- District (Northern Ireland), replaced by Mid Ulster in 2015. Added (historical).
    ('2323', 'Southend-on-Sea', '232'), -- Unitary Authority (England)
    ('2324', 'Armagh, Banbridge and Craigavon', '232'), -- District (Northern Ireland)
    ('2325', 'Perth and Kinross', '232'), -- Council Area (Scotland)
    ('2326', 'London Borough of Waltham Forest', '232'), -- Borough (England)
    ('2327', 'Rochdale', '232'), -- Metropolitan Borough (England)
    ('2328', 'Merthyr Tydfil County Borough', '232'), -- Principal Area (Wales)
    ('2329', 'Blackburn with Darwen', '232'), -- Unitary Authority (England)
    ('2330', 'Knowsley', '232'), -- Metropolitan Borough (England)
    (
        '2331',
        'Armagh City and District Council (historical)',
        '232'
    ), -- District (Northern Ireland), replaced by Armagh, Banbridge and Craigavon in 2015. Added (historical).
    ('2332', 'Middlesbrough', '232'), -- Unitary Authority (England)
    ('2333', 'East Renfrewshire', '232'), -- Council Area (Scotland)
    ('2334', 'Cumbria (historical)', '232'), -- County (England), abolished 2023, split into Cumberland and Westmorland and Furness. Added (historical).
    ('2335', 'Scotland', '232'), -- Country
    ('2336', 'England', '232'), -- Country
    ('2337', 'Northern Ireland', '232'), -- Country
    ('2338', 'Wales', '232'), -- Country (Cymru)
    ('2339', 'Bath and North East Somerset', '232'), -- Unitary Authority (England)
    ('2340', 'Liverpool', '232'), -- Metropolitan Borough (England)
    ('2341', 'Sandwell', '232'), -- Metropolitan Borough (England)
    ('2342', 'Bournemouth (historical)', '232'), -- Unitary Authority (England), merged into Bournemouth, Christchurch and Poole in 2019. Added (historical).
    ('2343', 'Isles of Scilly', '232'), -- Unitary Authority (England - Sui generis)
    ('2344', 'Falkirk', '232'), -- Council Area (Scotland)
    ('2345', 'Dorset', '232'), -- Unitary Authority (England) (Note: Historical county was larger)
    ('2346', 'Scottish Borders', '232'), -- Council Area (Scotland)
    ('2347', 'London Borough of Havering', '232'), -- Borough (England)
    (
        '2348',
        'Moyle District Council (historical)',
        '232'
    ), -- District (Northern Ireland), replaced by Causeway Coast and Glens in 2015. Added (historical).
    ('2349', 'London Borough of Camden', '232'), -- Borough (England)
    (
        '2350',
        'Newry and Mourne District Council (historical)',
        '232'
    ), -- District (Northern Ireland), replaced by Newry, Mourne and Down in 2015. Added (historical).
    ('2351', 'Neath Port Talbot', '232'), -- Changed Neath Port Talbot County Borough to Neath Port Talbot (Principal Area - Wales)
    ('2352', 'Conwy County Borough', '232'), -- Principal Area (Wales)
    (
        '2353',
        'Na h-Eileanan Siar (Outer Hebrides)',
        '232'
    ), -- Changed Outer Hebrides to Na h-Eileanan Siar (Outer Hebrides) (Council Area - Scotland)
    ('2354', 'West Lothian', '232'), -- Council Area (Scotland)
    ('2355', 'Lincolnshire', '232'), -- County (England)
    (
        '2356',
        'London Borough of Barking and Dagenham',
        '232'
    ), -- Borough (England)
    ('2357', 'City of Westminster', '232'), -- Borough / City (England)
    ('2358', 'London Borough of Lewisham', '232'), -- Borough (England)
    ('2359', 'City of Nottingham', '232'), -- Unitary Authority (England)
    ('2360', 'Moray', '232'), -- Council Area (Scotland)
    ('2361', 'Ballymoney (historical)', '232'), -- Borough Council (Northern Ireland), replaced by Causeway Coast and Glens in 2015. Added (historical).
    ('2362', 'South Lanarkshire', '232'), -- Council Area (Scotland)
    ('2363', 'Ballymena Borough (historical)', '232'), -- Borough (Northern Ireland), replaced by Mid and East Antrim in 2015. Added (historical).
    ('2364', 'Doncaster', '232'), -- Metropolitan Borough (England)
    ('2365', 'Northumberland', '232'), -- Unitary Authority (England)
    ('2366', 'Fermanagh and Omagh', '232'), -- District (Northern Ireland)
    ('2367', 'Tameside', '232'), -- Metropolitan Borough (England)
    (
        '2368',
        'Royal Borough of Kensington and Chelsea',
        '232'
    ), -- Borough (England)
    ('2369', 'Hertfordshire', '232'), -- County (England)
    ('2370', 'East Riding of Yorkshire', '232'), -- Unitary Authority (England)
    ('2371', 'Kirklees', '232'), -- Metropolitan Borough (England)
    ('2372', 'City of Sunderland', '232'), -- Metropolitan Borough (England)
    ('2373', 'Gloucestershire', '232'), -- County (England)
    ('2374', 'East Ayrshire', '232'), -- Council Area (Scotland)
    ('2375', 'United Kingdom', '232'), -- Sovereign state (entry seems redundant in a states table)
    ('2376', 'London Borough of Hillingdon', '232'), -- Borough (England)
    ('2377', 'South Ayrshire', '232'), -- Council Area (Scotland)
    ('2378', 'Ascension Island', '232'), -- Part of Saint Helena, Ascension and Tristan da Cunha (British Overseas Territory)
    ('2379', 'Gwynedd', '232'), -- Principal Area (Wales)
    ('2380', 'London Borough of Hounslow', '232'), -- Borough (England)
    ('2381', 'Medway', '232'), -- Unitary Authority (England)
    (
        '2382',
        'Limavady Borough Council (historical)',
        '232'
    ), -- Borough (Northern Ireland), replaced by Causeway Coast and Glens in 2015. Added (historical).
    ('2383', 'Highland', '232'), -- Council Area (Scotland)
    ('2384', 'North East Lincolnshire', '232'), -- Unitary Authority (England)
    ('2385', 'London Borough of Harrow', '232'), -- Borough (England)
    ('2386', 'Somerset', '232'), -- Unitary Authority (England) (Changed from County status in 2023)
    ('2387', 'Angus', '232'), -- Council Area (Scotland)
    ('2388', 'Inverclyde', '232'), -- Council Area (Scotland)
    ('2389', 'Darlington', '232'), -- Unitary Authority (England)
    ('2390', 'London Borough of Tower Hamlets', '232'), -- Borough (England)
    ('2391', 'Wiltshire', '232'), -- Unitary Authority (England)
    ('2392', 'Argyll and Bute', '232'), -- Council Area (Scotland)
    (
        '2393',
        'Strabane District Council (historical)',
        '232'
    ), -- District (Northern Ireland), replaced by Derry City and Strabane in 2015. Added (historical).
    ('2394', 'Stockport', '232'), -- Metropolitan Borough (England)
    ('2395', 'Brighton and Hove', '232'), -- Unitary Authority (England)
    ('2396', 'London Borough of Lambeth', '232'), -- Borough (England)
    ('2397', 'London Borough of Redbridge', '232'), -- Borough (England)
    ('2398', 'Manchester', '232'), -- Metropolitan Borough (England)
    ('2399', 'Mid Ulster', '232'), -- District (Northern Ireland)
    ('2400', 'South Gloucestershire', '232'), -- Unitary Authority (England)
    ('2401', 'Aberdeenshire', '232'), -- Council Area (Scotland)
    ('2402', 'Monmouthshire', '232'), -- Principal Area (Wales)
    ('2403', 'Derbyshire', '232'), -- County (England)
    ('2404', 'Glasgow City', '232'), -- Changed Glasgow to Glasgow City (Council Area / City - Scotland)
    ('2405', 'Buckinghamshire', '232'), -- Unitary Authority (England) (Changed from County status in 2020)
    ('2406', 'County Durham', '232'), -- Unitary Authority (England)
    ('2407', 'Shropshire', '232'), -- Unitary Authority (England)
    ('2408', 'Wirral', '232'), -- Metropolitan Borough (England)
    ('2409', 'South Tyneside', '232'), -- Metropolitan Borough (England)
    ('2410', 'Essex', '232'), -- County (England)
    ('2411', 'London Borough of Hackney', '232'), -- Borough (England)
    ('2412', 'Antrim and Newtownabbey', '232'), -- District (Northern Ireland)
    ('2413', 'City of Bristol', '232'), -- Unitary Authority / County / City (England)
    ('2414', 'East Sussex', '232'), -- County (England)
    ('2415', 'Dumfries and Galloway', '232'), -- Council Area (Scotland)
    ('2416', 'Milton Keynes', '232'), -- Unitary Authority (England)
    ('2417', 'Derry City Council (historical)', '232'), -- District (Northern Ireland), replaced by Derry City and Strabane in 2015. Added (historical).
    ('2418', 'London Borough of Newham', '232'), -- Borough (England)
    ('2419', 'Wokingham', '232'), -- Unitary Authority (England)
    ('2420', 'Warrington', '232'), -- Unitary Authority (England)
    ('2421', 'Stockton-on-Tees', '232'), -- Unitary Authority (England)
    ('2422', 'Swindon', '232'), -- Unitary Authority (England)
    ('2423', 'Cambridgeshire', '232'), -- County (England)
    ('2424', 'City of London', '232'), -- City / County (England - Sui generis)
    ('2425', 'Birmingham', '232'), -- Metropolitan Borough / City (England)
    ('2426', 'City of York', '232'), -- Unitary Authority (England)
    ('2427', 'Slough', '232'), -- Unitary Authority (England)
    ('2428', 'City of Edinburgh', '232'), -- Changed Edinburgh to City of Edinburgh (Council Area / City - Scotland)
    ('2429', 'Mid and East Antrim', '232'), -- District (Northern Ireland)
    ('2430', 'North Somerset', '232'), -- Unitary Authority (England)
    ('2431', 'Gateshead', '232'), -- Metropolitan Borough (England)
    ('2432', 'London Borough of Southwark', '232'), -- Borough (England)
    ('2433', 'Swansea', '232'), -- Changed City and County of Swansea to Swansea (Principal Area / City - Wales)
    ('2434', 'London Borough of Wandsworth', '232'), -- Borough (England)
    ('2435', 'Hampshire', '232'), -- County (England)
    ('2436', 'Wrexham County Borough', '232'), -- Principal Area / City (Wales)
    ('2437', 'Flintshire', '232'), -- Principal Area (Wales)
    ('2438', 'Coventry', '232'), -- Metropolitan Borough / City (England)
    (
        '2439',
        'Carrickfergus Borough Council (historical)',
        '232'
    ), -- Borough (Northern Ireland), replaced by Mid and East Antrim in 2015. Added (historical).
    ('2440', 'West Dunbartonshire', '232'), -- Council Area (Scotland)
    ('2441', 'Powys', '232'), -- Principal Area (Wales)
    ('2442', 'Cheshire West and Chester', '232'), -- Unitary Authority (England)
    ('2443', 'Renfrewshire', '232'), -- Council Area (Scotland)
    ('2444', 'Cheshire East', '232'), -- Unitary Authority (England)
    (
        '2445',
        'Cookstown District Council (historical)',
        '232'
    ), -- District (Northern Ireland), replaced by Mid Ulster in 2015. Added (historical).
    ('2446', 'Derry City and Strabane', '232'), -- District (Northern Ireland)
    ('2447', 'Staffordshire', '232'), -- County (England)
    (
        '2448',
        'London Borough of Hammersmith and Fulham',
        '232'
    ), -- Borough (England)
    (
        '2449',
        'Craigavon Borough Council (historical)',
        '232'
    ), -- Borough (Northern Ireland), replaced by Armagh, Banbridge and Craigavon in 2015. Added (historical).
    ('2450', 'Clackmannanshire', '232'), -- Council Area (Scotland)
    ('2451', 'Blackpool', '232'), -- Unitary Authority (England)
    ('2452', 'Bridgend County Borough', '232'), -- Principal Area (Wales)
    ('2453', 'North Lincolnshire', '232'), -- Unitary Authority (England)
    ('2454', 'East Dunbartonshire', '232'), -- Council Area (Scotland)
    ('2455', 'Reading', '232'), -- Unitary Authority (England)
    ('2456', 'Nottinghamshire', '232'), -- County (England)
    ('2457', 'Dudley', '232'), -- Metropolitan Borough (England)
    ('2458', 'Newcastle upon Tyne', '232'), -- Metropolitan Borough / City (England)
    ('2459', 'Bury', '232'), -- Metropolitan Borough (England)
    ('2460', 'Lisburn and Castlereagh', '232'), -- District / City (Northern Ireland)
    (
        '2461',
        'Coleraine Borough Council (historical)',
        '232'
    ), -- Borough (Northern Ireland), replaced by Causeway Coast and Glens in 2015. Added (historical).
    ('2462', 'East Lothian', '232'), -- Council Area (Scotland)
    ('2463', 'Aberdeen City', '232'), -- Changed Aberdeen to Aberdeen City (Council Area / City - Scotland)
    ('2464', 'Kent', '232'), -- County (England)
    ('2465', 'Wakefield', '232'), -- Metropolitan Borough / City (England)
    ('2466', 'Halton', '232'), -- Unitary Authority (England)
    ('2467', 'Suffolk', '232'), -- County (England)
    ('2468', 'Thurrock', '232'), -- Unitary Authority (England)
    ('2469', 'Solihull', '232'), -- Metropolitan Borough (England)
    ('2470', 'Bracknell Forest', '232'), -- Unitary Authority (England)
    ('2471', 'West Berkshire', '232'), -- Unitary Authority (England)
    ('2472', 'Rutland', '232'), -- Unitary Authority / County (England)
    ('2473', 'Norfolk', '232'), -- County (England)
    ('2474', 'Orkney Islands', '232'), -- Council Area (Scotland)
    ('2475', 'Kingston upon Hull', '232'), -- Changed City of Kingston upon Hull to Kingston upon Hull (Unitary Authority / City - England)
    ('2476', 'London Borough of Enfield', '232'), -- Borough (England)
    ('2477', 'Oldham', '232'), -- Metropolitan Borough (England)
    ('2478', 'Torbay', '232'), -- Unitary Authority (England)
    ('2479', 'Fife', '232'), -- Council Area (Scotland)
    ('2480', 'Northamptonshire (historical)', '232'), -- County (England), abolished 2021, split into North Northamptonshire and West Northamptonshire. Added (historical).
    (
        '2481',
        'Royal Borough of Kingston upon Thames',
        '232'
    ), -- Borough (England)
    (
        '2482',
        'Royal Borough of Windsor and Maidenhead',
        '232'
    ), -- Changed Windsor and Maidenhead to Royal Borough of Windsor and Maidenhead (Unitary Authority - England)
    ('2483', 'London Borough of Merton', '232'), -- Borough (England)
    ('2484', 'Carmarthenshire', '232'), -- Principal Area (Wales)
    ('2485', 'City of Derby', '232'), -- Unitary Authority (England)
    ('2486', 'Pembrokeshire', '232'), -- Principal Area (Wales)
    ('2487', 'North Lanarkshire', '232'), -- Council Area (Scotland)
    ('2488', 'Stirling', '232'), -- Council Area / City (Scotland)
    ('2489', 'City of Wolverhampton', '232'), -- Metropolitan Borough (England)
    ('2490', 'London Borough of Bromley', '232'), -- Borough (England)
    ('2491', 'Devon', '232'), -- County (England)
    ('2492', 'Royal Borough of Greenwich', '232'), -- Borough (England)
    ('2493', 'Salford', '232'), -- Metropolitan Borough / City (England)
    (
        '2494',
        'Lisburn City Council (historical)',
        '232'
    ), -- City (Northern Ireland), replaced by Lisburn and Castlereagh in 2015. Added (historical).
    ('2495', 'Lancashire', '232'), -- County (England)
    ('2496', 'Torfaen', '232'), -- Principal Area (Wales)
    ('2497', 'Denbighshire', '232'), -- Principal Area (Wales)
    (
        '2498',
        'Ards Borough Council (historical)',
        '232'
    ), -- Changed Ards to Ards Borough Council (historical) (Borough - Northern Ireland), replaced by Ards and North Down in 2015.
    ('2499', 'Barnsley', '232'), -- Metropolitan Borough (England)
    ('2500', 'Herefordshire', '232'), -- Unitary Authority / County (England)
    (
        '2501',
        'London Borough of Richmond upon Thames',
        '232'
    ), -- Borough (England)
    ('2502', 'Saint Helena', '232'), -- Part of Saint Helena, Ascension and Tristan da Cunha (British Overseas Territory)
    ('2503', 'Leeds', '232'), -- Metropolitan Borough / City (England)
    ('2504', 'Bolton', '232'), -- Metropolitan Borough (England)
    ('2505', 'Warwickshire', '232'), -- County (England)
    ('2506', 'City of Stoke-on-Trent', '232'), -- Unitary Authority (England)
    ('2507', 'Bedford', '232'), -- Unitary Authority (England)
    (
        '2508',
        'Dungannon and South Tyrone Borough Council (historical)',
        '232'
    ), -- Borough (Northern Ireland), replaced by Mid Ulster in 2015. Added (historical).
    ('2509', 'Ceredigion', '232'), -- Principal Area (Wales)
    ('2510', 'Worcestershire', '232'), -- County (England)
    ('2511', 'Dundee City', '232'), -- Changed Dundee to Dundee City (Council Area / City - Scotland)
    ('2512', 'London Borough of Croydon', '232'), -- Borough (England)
    (
        '2513',
        'North Down Borough Council (historical)',
        '232'
    ), -- Borough (Northern Ireland), replaced by Ards and North Down in 2015. Added (historical).
    ('2514', 'City of Plymouth', '232'), -- Unitary Authority (England)
    (
        '2515',
        'Larne Borough Council (historical)',
        '232'
    ), -- Borough (Northern Ireland), replaced by Mid and East Antrim in 2015. Added (historical).
    ('2516', 'Leicestershire', '232'), -- County (England)
    ('2517', 'Calderdale', '232'), -- Metropolitan Borough (England)
    ('2518', 'Sefton', '232'), -- Metropolitan Borough (England)
    ('2519', 'Midlothian', '232'), -- Council Area (Scotland)
    ('2520', 'London Borough of Barnet', '232'), -- Borough (England)
    ('2521', 'North Tyneside', '232'), -- Metropolitan Borough (England)
    ('2522', 'North Yorkshire', '232'), -- Unitary Authority (England) (Changed from County status in 2023)
    ('2523', 'Ards and North Down', '232'), -- District (Northern Ireland)
    ('2524', 'Newport', '232'), -- Principal Area / City (Wales)
    ('2525', 'Castlereagh (historical)', '232'), -- Borough Council (Northern Ireland), replaced by Lisburn and Castlereagh in 2015. Added (historical).
    ('2526', 'Surrey', '232'), -- County (England)
    ('2527', 'Redcar and Cleveland', '232'), -- Unitary Authority (England)
    ('2528', 'Cardiff', '232'), -- Changed City and County of Cardiff to Cardiff (Principal Area / City - Wales)
    ('2529', 'Bradford', '232'), -- Metropolitan Borough / City (England)
    ('2530', 'Blaenau Gwent County Borough', '232'), -- Principal Area (Wales)
    (
        '2531',
        'Fermanagh District Council (historical)',
        '232'
    ), -- District (Northern Ireland), replaced by Fermanagh and Omagh in 2015. Added (historical).
    ('2532', 'London Borough of Ealing', '232'), -- Borough (England)
    (
        '2533',
        'Antrim Borough Council (historical)',
        '232'
    ), -- Changed Antrim to Antrim Borough Council (historical) (Borough - Northern Ireland), replaced by Antrim and Newtownabbey in 2015.
    ('2534', 'Newry, Mourne and Down', '232'), -- District (Northern Ireland)
    ('2535', 'North Ayrshire', '232'), -- Council Area (Scotland)
    ('2536', 'Tashkent City', '236'), -- Changed Tashkent to Tashkent City (City - Capital)
    ('2537', 'Namangan Region', '236'), -- Viloyat
    ('2538', 'Fergana Region', '236'), -- Viloyat
    ('2539', 'Xorazm Region', '236'), -- Viloyat (Khorezm)
    ('2540', 'Andijan Region', '236'), -- Viloyat
    ('2541', 'Bukhara Region', '236'), -- Viloyat
    ('2542', 'Navoiy Region', '236'), -- Viloyat (Navoi)
    ('2543', 'Qashqadaryo Region', '236'), -- Viloyat (Kashkadarya)
    ('2544', 'Samarqand Region', '236'), -- Viloyat (Samarkand)
    ('2545', 'Jizzakh Region', '236'), -- Viloyat
    ('2546', 'Surxondaryo Region', '236'), -- Viloyat (Surkhandarya)
    ('2547', 'Sirdaryo Region', '236'), -- Viloyat (Syrdarya)
    ('2548', 'Republic of Karakalpakstan', '236'), -- Changed Karakalpakstan to Republic of Karakalpakstan (Autonomous Republic)
    ('2549', 'Tashkent Region', '236'), -- Viloyat
    ('2550', 'Ariana Governorate', '224'),
    ('2551', 'Bizerte Governorate', '224'),
    ('2552', 'Jendouba Governorate', '224'),
    ('2553', 'Monastir Governorate', '224'),
    ('2554', 'Tunis Governorate', '224'),
    ('2555', 'Manouba Governorate', '224'),
    ('2556', 'Gafsa Governorate', '224'),
    ('2557', 'Sfax Governorate', '224'),
    ('2558', 'Gabès Governorate', '224'), -- Gabès has 'è'
    ('2559', 'Tataouine Governorate', '224'),
    ('2560', 'Medenine Governorate', '224'), -- Médenine has 'é'
    ('2561', 'Kef Governorate', '224'), -- Le Kef
    ('2562', 'Kebili Governorate', '224'), -- Kébili has 'é'
    ('2563', 'Siliana Governorate', '224'),
    ('2564', 'Kairouan Governorate', '224'),
    ('2565', 'Zaghouan Governorate', '224'),
    ('2566', 'Ben Arous Governorate', '224'),
    ('2567', 'Sidi Bouzid Governorate', '224'),
    ('2568', 'Mahdia Governorate', '224'),
    ('2569', 'Tozeur Governorate', '224'),
    ('2570', 'Kasserine Governorate', '224'),
    ('2571', 'Sousse Governorate', '224'),
    ('2572', 'Kasserine Governorate', '224'), -- Duplicate of 2570, likely error. Changed Kassrine to Kasserine Governorate. Consider removing duplicate.
    ('2573', 'Ratak Chain', '137'), -- Island chain / municipality group
    ('2574', 'Ralik Chain', '137'), -- Island chain / municipality group
    ('2575', 'Centrale Region', '220'), -- Centrale has 'e' (Region)
    ('2576', 'Maritime Region', '220'), -- Changed Maritime to Maritime Region (Region)
    ('2577', 'Plateaux Region', '220'), -- (Region)
    ('2578', 'Savanes Region', '220'), -- (Region)
    ('2579', 'Kara Region', '220'), -- (Region)
    ('2580', 'Chuuk State', '143'),
    ('2581', 'Pohnpei State', '143'),
    ('2582', 'Yap State', '143'),
    ('2583', 'Kosrae State', '143'),
    ('2584', 'Vaavu Atoll', '133'), -- Felidhu Atoll (Administrative Atoll)
    ('2585', 'Shaviyani Atoll', '133'), -- Miladhunmadulu Uthuruburi (Administrative Atoll)
    ('2586', 'Haa Alif Atoll', '133'), -- Thiladhunmathi Uthuruburi (Administrative Atoll)
    ('2587', 'Alif Alif Atoll', '133'), -- Ari Atholhu Uthuruburi (Administrative Atoll)
    ('2588', 'North Province (historical)', '133'), -- Abolished, Added (historical)
    (
        '2589',
        'North Central Province (historical)',
        '133'
    ), -- Abolished, Added (historical)
    ('2590', 'Dhaalu Atoll', '133'), -- Nilandhe Atholhu Dhekunuburi (Administrative Atoll)
    ('2591', 'Thaa Atoll', '133'), -- Kolhumadulu (Administrative Atoll)
    ('2592', 'Noonu Atoll', '133'), -- Miladhunmadulu Dhekunuburi (Administrative Atoll)
    (
        '2593',
        'Upper South Province (historical)',
        '133'
    ), -- Abolished, Added (historical)
    ('2594', 'Addu Atoll', '133'), -- Seenu (Administrative Atoll / City)
    ('2595', 'Gnaviyani Atoll', '133'), -- Fuvahmulah (Administrative Atoll / City)
    ('2596', 'Kaafu Atoll', '133'), -- Maale Atholhu (Administrative Atoll)
    ('2597', 'Haa Dhaalu Atoll', '133'), -- Thiladhunmathi Dhekunuburi (Administrative Atoll)
    ('2598', 'Gaafu Alif Atoll', '133'), -- Huvadhu Atholhu Uthuruburi (Administrative Atoll)
    ('2599', 'Faafu Atoll', '133'), -- Nilandhe Atholhu Uthuruburi (Administrative Atoll)
    ('2600', 'Alif Dhaal Atoll', '133'), -- Ari Atholhu Dhekunuburi (Administrative Atoll)
    ('2601', 'Laamu Atoll', '133'), -- Hahdhunmathi (Administrative Atoll)
    ('2602', 'Raa Atoll', '133'), -- Maalhosmadulu Uthuruburi (Administrative Atoll)
    ('2603', 'Gaafu Dhaalu Atoll', '133'), -- Huvadhu Atholhu Dhekunuburi (Administrative Atoll)
    ('2604', 'Central Province (historical)', '133'), -- Abolished, Added (historical)
    ('2605', 'South Province (historical)', '133'), -- Abolished, Added (historical)
    (
        '2606',
        'South Central Province (historical)',
        '133'
    ), -- Abolished, Added (historical)
    ('2607', 'Lhaviyani Atoll', '133'), -- Faadhippolhu (Administrative Atoll)
    ('2608', 'Meemu Atoll', '133'), -- Mulaku Atholhu (Administrative Atoll)
    ('2609', 'Malé', '133'), -- Malé has 'é' (Capital City)
    ('2610', 'Utrecht', '156'), -- Province
    ('2611', 'Gelderland', '156'), -- Province
    ('2612', 'North Holland', '156'), -- Province (Noord-Holland)
    ('2613', 'Drenthe', '156'), -- Province
    ('2614', 'South Holland', '156'), -- Province (Zuid-Holland)
    ('2615', 'Limburg', '156'), -- Province
    ('2616', 'Sint Eustatius', '156'), -- Special Municipality
    ('2617', 'Groningen', '156'), -- Province
    ('2618', 'Overijssel', '156'), -- Province
    ('2619', 'Flevoland', '156'), -- Province
    ('2620', 'Zeeland', '156'), -- Province
    ('2621', 'Saba', '156'), -- Special Municipality
    ('2622', 'Friesland', '156'), -- Province (Fryslân)
    ('2623', 'North Brabant', '156'), -- Province (Noord-Brabant)
    ('2624', 'Bonaire', '156'), -- Special Municipality
    ('2625', 'Savanes Region', '54'), -- Note: Côte d'Ivoire regions reorganized in 2011. This lists older regions and newer districts. Savanes exists in both structures.
    ('2626', 'Agnéby Region (historical)', '54'), -- Changed Agnéby to Agnéby Region (historical). Merged into Lagunes District. Agnéby has 'é'.
    ('2627', 'Lagunes District', '54'),
    ('2628', 'Sud-Bandama Region (historical)', '54'), -- Merged into Gôh-Djiboua District and Bas-Sassandra District. Added (historical).
    ('2629', 'Montagnes District', '54'),
    ('2630', 'Moyen-Comoé Region (historical)', '54'), -- Merged into Comoé District. Added (historical). Moyen-Comoé has 'é'.
    ('2631', 'Marahoué Region', '54'), -- Marahoué has 'é'. Part of Sassandra-Marahoué District.
    ('2632', 'Lacs District', '54'),
    ('2633', 'Fromager Region (historical)', '54'), -- Merged into Gôh-Djiboua District. Added (historical).
    ('2634', 'Abidjan Autonomous District', '54'), -- Changed Abidjan to Abidjan Autonomous District.
    ('2635', 'Bas-Sassandra Region (historical)', '54'), -- Changed Bas-Sassandra Region to Bas-Sassandra Region (historical). Now part of Bas-Sassandra District.
    ('2636', 'Bafing Region', '54'), -- Part of Woroba District.
    ('2637', 'Vallée du Bandama District', '54'), -- Vallée has 'é'.
    ('2638', 'Haut-Sassandra Region', '54'), -- Changed Haut-Sassandra to Haut-Sassandra Region. Part of Sassandra-Marahoué District.
    ('2639', 'Lagunes Region (historical)', '54'), -- Changed Lagunes region to Lagunes Region (historical). Merged into Lagunes District and Abidjan.
    ('2640', 'Lacs Region (historical)', '54'), -- Merged into Lacs District and Yamoussoukro District. Added (historical).
    ('2641', 'Zanzan Region (historical)', '54'), -- Now part of Zanzan District. Added (historical).
    ('2642', 'Denguélé Region (historical)', '54'), -- Changed Denguélé Region to Denguélé Region (historical). Now part of Denguélé District. Denguélé has 'é'.
    ('2643', 'Bas-Sassandra District', '54'),
    ('2644', 'Denguélé District', '54'), -- Denguélé has 'é'.
    (
        '2645',
        'Dix-Huit Montagnes Region (historical)',
        '54'
    ), -- Changed Dix-Huit Montagnes to Dix-Huit Montagnes Region (historical). Merged into Montagnes District.
    ('2646', 'Moyen-Cavally Region (historical)', '54'), -- Merged into Montagnes District. Added (historical).
    (
        '2647',
        'Vallée du Bandama Region (historical)',
        '54'
    ), -- Changed Vallée du Bandama Region to Vallée du Bandama Region (historical). Now part of Vallée du Bandama District. Vallée has 'é'.
    ('2648', 'Sassandra-Marahoué District', '54'), -- Marahoué has 'é'.
    ('2649', 'Worodougou Region', '54'), -- Changed Worodougou to Worodougou Region. Part of Woroba District.
    ('2650', 'Woroba District', '54'),
    ('2651', 'Gôh-Djiboua District', '54'),
    ('2652', 'Sud-Comoé Region', '54'), -- Changed Sud-Comoé to Sud-Comoé Region. Part of Comoé District. Sud-Comoé has 'é'.
    ('2653', 'Yamoussoukro Autonomous District', '54'), -- Changed Yamoussoukro to Yamoussoukro Autonomous District.
    ('2654', 'Comoé District', '54'), -- Comoé has 'é'.
    ('2655', 'N''zi-Comoé Region (historical)', '54'), -- Fixed escaping, Merged into Lacs District and Comoé District. Added (historical). Comoé has 'é'.
    ('2656', 'Far North Region', '38'), -- Extrême-Nord
    ('2657', 'Northwest Region', '38'), -- Nord-Ouest
    ('2658', 'Southwest Region', '38'), -- Sud-Ouest
    ('2659', 'South Region', '38'), -- Sud
    ('2660', 'Centre Region', '38'), -- Centre
    ('2661', 'East Region', '38'), -- Est
    ('2662', 'Littoral Region', '38'),
    ('2663', 'Adamawa Region', '38'), -- Adamaoua
    ('2664', 'West Region', '38'), -- Ouest
    ('2665', 'North Region', '38'), -- Nord
    ('2666', 'Banjul', '80'), -- City / LGA
    ('2667', 'West Coast Region', '80'), -- LGA (formerly Western Division)
    ('2668', 'Upper River Region', '80'), -- Changed Upper River Division to Upper River Region (LGA)
    ('2669', 'Central River Region', '80'), -- Changed Central River Division to Central River Region (LGA)
    ('2670', 'Lower River Region', '80'), -- Changed Lower River Division to Lower River Region (LGA)
    ('2671', 'North Bank Region', '80'), -- Changed North Bank Division to North Bank Region (LGA)
    ('2672', 'Beyla Prefecture', '92'),
    ('2673', 'Mandiana Prefecture', '92'),
    ('2674', 'Yomou Prefecture', '92'),
    ('2675', 'Fria Prefecture', '92'),
    ('2676', 'Boké Region', '92'), -- Boké has 'é'
    ('2677', 'Labé Region', '92'), -- Labé has 'é'
    ('2678', 'Nzérékoré Prefecture', '92'), -- Nzérékoré has 'é'
    ('2679', 'Dabola Prefecture', '92'),
    ('2680', 'Labé Prefecture', '92'), -- Labé has 'é'
    ('2681', 'Dubréka Prefecture', '92'), -- Dubréka has 'é'
    ('2682', 'Faranah Prefecture', '92'),
    ('2683', 'Forécariah Prefecture', '92'), -- Forécariah has 'é'
    ('2684', 'Nzérékoré Region', '92'), -- Nzérékoré has 'é'
    ('2685', 'Gaoual Prefecture', '92'),
    ('2686', 'Conakry', '92'), -- Special Zone / Capital Region
    ('2687', 'Télimélé Prefecture', '92'), -- Télimélé has 'é'
    ('2688', 'Dinguiraye Prefecture', '92'),
    ('2689', 'Mamou Prefecture', '92'),
    ('2690', 'Lélouma Prefecture', '92'), -- Lélouma has 'é'
    ('2691', 'Kissidougou Prefecture', '92'),
    ('2692', 'Koubia Prefecture', '92'),
    ('2693', 'Kindia Prefecture', '92'),
    ('2694', 'Pita Prefecture', '92'),
    ('2695', 'Kouroussa Prefecture', '92'),
    ('2696', 'Tougué Prefecture', '92'), -- Tougué has 'é'
    ('2697', 'Kankan Region', '92'),
    ('2698', 'Mamou Region', '92'),
    ('2699', 'Boffa Prefecture', '92'),
    ('2700', 'Mali Prefecture', '92'), -- (Yembering)
    ('2701', 'Kindia Region', '92'),
    ('2702', 'Macenta Prefecture', '92'),
    ('2703', 'Koundara Prefecture', '92'),
    ('2704', 'Kankan Prefecture', '92'),
    ('2705', 'Coyah Prefecture', '92'),
    ('2706', 'Dalaba Prefecture', '92'),
    ('2707', 'Siguiri Prefecture', '92'),
    ('2708', 'Lola Prefecture', '92'),
    ('2709', 'Boké Prefecture', '92'), -- Boké has 'é'
    ('2710', 'Kérouané Prefecture', '92'), -- Kérouané has 'é'
    ('2711', 'Guéckédou Prefecture', '92'), -- Guéckédou has 'é'
    ('2712', 'Tombali Region', '93'),
    ('2713', 'Cacheu Region', '93'),
    ('2714', 'Biombo Region', '93'),
    ('2715', 'Quinara Region', '93'),
    ('2716', 'Sul Province (historical)', '93'), -- Province abolished, Added (historical)
    ('2717', 'Norte Province (historical)', '93'), -- Province abolished, Added (historical)
    ('2718', 'Oio Region', '93'),
    ('2719', 'Gabú Region', '93'), -- Gabú has 'ú'
    ('2720', 'Bafatá Region', '93'), -- Changed Bafatá to Bafatá Region
    ('2721', 'Leste Province (historical)', '93'), -- Province abolished, Added (historical)
    ('2722', 'Bolama Region', '93'),
    ('2723', 'Woleu-Ntem Province', '79'),
    ('2724', 'Ogooué-Ivindo Province', '79'), -- Ogooué has 'é'
    ('2725', 'Nyanga Province', '79'),
    ('2726', 'Haut-Ogooué Province', '79'), -- Ogooué has 'é'
    ('2727', 'Estuaire Province', '79'),
    ('2728', 'Ogooué-Maritime Province', '79'), -- Ogooué has 'é'
    ('2729', 'Ogooué-Lolo Province', '79'), -- Ogooué has 'é'
    ('2730', 'Moyen-Ogooué Province', '79'), -- Ogooué has 'é'
    ('2731', 'Ngounié Province', '79'), -- Ngounié has 'é'
    ('2732', 'Tshuapa', '51'), -- Changed Tshuapa District to Tshuapa (Province since 2015)
    ('2733', 'Tanganyika Province', '51'), -- (Province since 2015)
    ('2734', 'Haut-Uele', '51'), -- Changed Haut-Uele to Haut-Uele (Province since 2015), Uele has 'é'
    ('2735', 'Kasaï-Oriental', '51'), -- Kasaï has 'ï' (Province - size reduced in 2015)
    ('2736', 'Orientale Province (historical)', '51'), -- Abolished 2015, Added (historical)
    ('2737', 'Kasaï-Central', '51'), -- Changed Kasaï-Occidental to Kasaï-Central (Province since 2015), Kasaï has 'ï'
    ('2738', 'South Kivu', '51'), -- Sud-Kivu (Province)
    ('2739', 'Nord-Ubangi', '51'), -- Changed Nord-Ubangi District to Nord-Ubangi (Province since 2015)
    ('2740', 'Kwango', '51'), -- Changed Kwango District to Kwango (Province since 2015)
    ('2741', 'Kinshasa', '51'), -- City-Province
    ('2742', 'Katanga Province (historical)', '51'), -- Abolished 2015, Added (historical)
    ('2743', 'Sankuru', '51'), -- Changed Sankuru District to Sankuru (Province since 2015)
    ('2744', 'Équateur', '51'), -- Équateur has 'É' (Province - size reduced in 2015)
    ('2745', 'Maniema', '51'), -- Province
    ('2746', 'Kongo Central', '51'), -- Changed Bas-Congo province to Kongo Central (Province, name changed 2015)
    ('2747', 'Lomami Province', '51'), -- (Province since 2015)
    ('2748', 'Sud-Ubangi', '51'), -- (Province since 2015)
    ('2749', 'North Kivu', '51'), -- Nord-Kivu (Province)
    ('2750', 'Haut-Katanga Province', '51'), -- (Province since 2015)
    ('2751', 'Ituri', '51'), -- Changed Ituri Interim Administration to Ituri (Province since 2015)
    ('2752', 'Mongala', '51'), -- Changed Mongala District to Mongala (Province since 2015)
    ('2753', 'Bas-Uele', '51'), -- Changed Bas-Uele to Bas-Uele (Province since 2015), Uele has 'é'
    ('2754', 'Bandundu Province (historical)', '51'), -- Abolished 2015, Added (historical)
    ('2755', 'Mai-Ndombe Province', '51'), -- (Province since 2015)
    ('2756', 'Tshopo', '51'), -- Changed Tshopo District to Tshopo (Province since 2015)
    ('2757', 'Kasaï', '51'), -- Changed Kasaï District to Kasaï (Province since 2015), Kasaï has 'ï'
    ('2758', 'Haut-Lomami', '51'), -- Changed Haut-Lomami District to Haut-Lomami (Province since 2015)
    ('2759', 'Kwilu', '51'), -- Changed Kwilu District to Kwilu (Province since 2015)
    ('2760', 'Cuyuni-Mazaruni', '94'), -- Region 7
    ('2761', 'Potaro-Siparuni', '94'), -- Region 8
    ('2762', 'Mahaica-Berbice', '94'), -- Region 5
    ('2763', 'Upper Demerara-Berbice', '94'), -- Region 10
    ('2764', 'Barima-Waini', '94'), -- Region 1
    ('2765', 'Pomeroon-Supenaam', '94'), -- Region 2
    ('2766', 'East Berbice-Corentyne', '94'), -- Region 6
    ('2767', 'Demerara-Mahaica', '94'), -- Region 4
    ('2768', 'Essequibo Islands-West Demerara', '94'), -- Region 3
    ('2769', 'Upper Takutu-Upper Essequibo', '94'), -- Region 9
    ('2770', 'Presidente Hayes Department', '172'),
    ('2771', 'Canindeyú Department', '172'), -- Changed Canindeyú to Canindeyú Department
    ('2772', 'Guairá Department', '172'), -- Guairá has 'á'
    ('2773', 'Caaguazú Department', '172'), -- Changed Caaguazú to Caaguazú Department
    ('2774', 'Paraguarí Department', '172'), -- Paraguarí has 'í'
    ('2775', 'Caazapá Department', '172'), -- Changed Caazapá to Caazapá Department
    ('2776', 'San Pedro Department', '172'),
    ('2777', 'Central Department', '172'),
    ('2778', 'Itapúa Department', '172'), -- Changed Itapúa to Itapúa Department
    ('2779', 'Concepción Department', '172'), -- Concepción has 'ó'
    ('2780', 'Boquerón Department', '172'), -- Boquerón has 'ó'
    ('2781', 'Ñeembucú Department', '172'), -- Ñeembucú has 'Ñ'
    ('2782', 'Amambay Department', '172'),
    ('2783', 'Cordillera Department', '172'),
    ('2784', 'Alto Paraná Department', '172'), -- Paraná has 'á'
    ('2785', 'Alto Paraguay Department', '172'),
    ('2786', 'Misiones Department', '172'),
    ('2787', 'Jaffna District', '208'),
    ('2788', 'Kandy District', '208'),
    ('2789', 'Kalutara District', '208'),
    ('2790', 'Badulla District', '208'),
    ('2791', 'Hambantota District', '208'),
    ('2792', 'Galle District', '208'),
    ('2793', 'Kilinochchi District', '208'),
    ('2794', 'Nuwara Eliya District', '208'),
    ('2795', 'Trincomalee District', '208'),
    ('2796', 'Puttalam District', '208'),
    ('2797', 'Kegalle District', '208'),
    ('2798', 'Central Province', '208'),
    ('2799', 'Ampara District', '208'),
    ('2800', 'North Central Province', '208'),
    ('2801', 'Southern Province', '208'),
    ('2802', 'Western Province', '208'),
    ('2803', 'Sabaragamuwa Province', '208'),
    ('2804', 'Gampaha District', '208'),
    ('2805', 'Mannar District', '208'),
    ('2806', 'Matara District', '208'),
    ('2807', 'Ratnapura District', '208'), -- Changed Ratnapura district to Ratnapura District
    ('2808', 'Eastern Province', '208'),
    ('2809', 'Vavuniya District', '208'),
    ('2810', 'Matale District', '208'),
    ('2811', 'Uva Province', '208'),
    ('2812', 'Polonnaruwa District', '208'),
    ('2813', 'Northern Province', '208'),
    ('2814', 'Mullaitivu District', '208'),
    ('2815', 'Colombo District', '208'),
    ('2816', 'Anuradhapura District', '208'),
    ('2817', 'North Western Province', '208'),
    ('2818', 'Batticaloa District', '208'),
    ('2819', 'Monaragala District', '208'),
    ('2820', 'Mohéli', '49'), -- Mohéli has 'é' (Autonomous island)
    ('2821', 'Anjouan', '49'), -- (Autonomous island)
    ('2822', 'Grande Comore', '49'), -- (Autonomous island - Ngazidja)
    ('2823', 'Atacama Region', '44'),
    ('2824', 'Santiago Metropolitan Region', '44'),
    ('2825', 'Coquimbo Region', '44'),
    ('2826', 'Araucanía Region', '44'), -- La Araucanía
    ('2827', 'Biobío Region', '44'), -- Changed Bío Bío to Biobío (common spelling without accent now), Region
    ('2828', 'Aysén Region', '44'), -- Aysén del General Carlos Ibáñez del Campo Region, Aysén has 'é'
    ('2829', 'Arica y Parinacota Region', '44'),
    ('2830', 'Valparaíso Region', '44'), -- Changed Valparaíso to Valparaíso Region, Valparaíso has 'í'
    ('2831', 'Ñuble Region', '44'), -- Ñuble has 'Ñ'
    ('2832', 'Antofagasta Region', '44'),
    ('2833', 'Maule Region', '44'),
    ('2834', 'Los Ríos Region', '44'), -- Ríos has 'í'
    ('2835', 'Los Lagos Region', '44'),
    (
        '2836',
        'Magallanes and Chilean Antarctica Region',
        '44'
    ), -- Changed Magellan and the Chilean Antarctic Region to Magallanes and Chilean Antarctica Region
    ('2837', 'Tarapacá Region', '44'), -- Tarapacá has 'á'
    ('2838', 'O''Higgins Region', '44'), -- Libertador General Bernardo O'Higgins Region, Fixed escaping
    ('2839', 'Commewijne District', '210'),
    ('2840', 'Nickerie District', '210'),
    ('2841', 'Para District', '210'),
    ('2842', 'Coronie District', '210'),
    ('2843', 'Paramaribo District', '210'), -- Capital District
    ('2844', 'Wanica District', '210'),
    ('2845', 'Marowijne District', '210'),
    ('2846', 'Brokopondo District', '210'),
    ('2847', 'Sipaliwini District', '210'),
    ('2848', 'Saramacca District', '210'),
    ('2849', 'Riyadh Region', '194'), -- Ar Riyāḍ
    ('2850', 'Makkah Region', '194'), -- Mecca Province
    ('2851', 'Al Madinah Region', '194'), -- Medina Province
    ('2852', 'Tabuk Region', '194'),
    ('2853', '''Asir Region', '194'), -- Fixed escaping ('Asīr)
    ('2854', 'Northern Borders Region', '194'), -- Al Ḥudūd ash Shamālīyah
    ('2855', 'Ha''il Region', '194'), -- Fixed escaping (Ḥā''il)
    ('2856', 'Eastern Province', '194'), -- Ash Sharqīyah
    ('2857', 'Al Jawf Region', '194'),
    ('2858', 'Jizan Region', '194'), -- Jāzān
    ('2859', 'Al Bahah Region', '194'), -- Al Bāḩah
    ('2860', 'Najran Region', '194'), -- Najrān
    ('2861', 'Al-Qassim Region', '194'), -- Al Qaṣīm
    ('2862', 'Plateaux Department', '50'),
    ('2863', 'Pointe-Noire Department', '50'), -- Changed Pointe-Noire to Pointe-Noire Department (department status since 2004)
    ('2864', 'Cuvette Department', '50'),
    ('2865', 'Likouala Department', '50'),
    ('2866', 'Bouenza Department', '50'),
    ('2867', 'Kouilou Department', '50'),
    ('2868', 'Lékoumou Department', '50'), -- Lékoumou has 'é'
    ('2869', 'Cuvette-Ouest Department', '50'),
    ('2870', 'Brazzaville Department', '50'), -- Changed Brazzaville to Brazzaville Department (department status)
    ('2871', 'Sangha Department', '50'),
    ('2872', 'Niari Department', '50'),
    ('2873', 'Pool Department', '50'),
    ('2874', 'Quindío Department', '48'), -- Quindío has 'í'
    ('2875', 'Cundinamarca Department', '48'),
    ('2876', 'Chocó Department', '48'), -- Chocó has 'ó'
    ('2877', 'Norte de Santander Department', '48'),
    ('2878', 'Meta Department', '48'), -- Changed Meta to Meta Department
    ('2879', 'Risaralda Department', '48'),
    ('2880', 'Atlántico Department', '48'), -- Atlántico has 'á'
    ('2881', 'Arauca Department', '48'),
    ('2882', 'Guainía Department', '48'), -- Guainía has 'í'
    ('2883', 'Tolima Department', '48'),
    ('2884', 'Cauca Department', '48'),
    ('2885', 'Vaupés Department', '48'), -- Vaupés has 'é'
    ('2886', 'Magdalena Department', '48'),
    ('2887', 'Caldas Department', '48'),
    ('2888', 'Guaviare Department', '48'),
    ('2889', 'La Guajira Department', '48'),
    ('2890', 'Antioquia Department', '48'),
    ('2891', 'Caquetá Department', '48'), -- Caquetá has 'á'
    ('2892', 'Casanare Department', '48'),
    ('2893', 'Bolívar Department', '48'), -- Bolívar has 'í'
    ('2894', 'Vichada Department', '48'),
    ('2895', 'Amazonas Department', '48'),
    ('2896', 'Putumayo Department', '48'),
    ('2897', 'Nariño Department', '48'), -- Nariño has 'ñ'
    ('2898', 'Córdoba Department', '48'), -- Córdoba has 'ó'
    ('2899', 'Cesar Department', '48'),
    (
        '2900',
        'Archipelago of San Andrés, Providencia and Santa Catalina Department',
        '48'
    ), -- Changed Archipelago of Saint Andréws... to Archipelago of San Andrés, Providencia and Santa Catalina Department, Andrés has 'é'
    ('2901', 'Santander Department', '48'),
    ('2902', 'Sucre Department', '48'),
    ('2903', 'Boyacá Department', '48'), -- Boyacá has 'á'
    ('2904', 'Valle del Cauca Department', '48'),
    ('2905', 'Galápagos Province', '64'), -- Galápagos has 'á'
    ('2906', 'Sucumbíos Province', '64'), -- Sucumbíos has 'í'
    ('2907', 'Pastaza Province', '64'),
    ('2908', 'Tungurahua Province', '64'),
    ('2909', 'Zamora-Chinchipe Province', '64'),
    ('2910', 'Los Ríos Province', '64'), -- Ríos has 'í'
    ('2911', 'Imbabura Province', '64'),
    ('2912', 'Santa Elena Province', '64'),
    ('2913', 'Manabí Province', '64'), -- Manabí has 'í'
    ('2914', 'Guayas Province', '64'),
    ('2915', 'Carchi Province', '64'),
    ('2916', 'Napo Province', '64'),
    ('2917', 'Cañar Province', '64'), -- Cañar has 'ñ'
    ('2918', 'Morona-Santiago Province', '64'),
    (
        '2919',
        'Santo Domingo de los Tsáchilas Province',
        '64'
    ), -- Tsáchilas has 'á'
    ('2920', 'Bolívar Province', '64'), -- Bolívar has 'í'
    ('2921', 'Cotopaxi Province', '64'),
    ('2922', 'Esmeraldas Province', '64'), -- Changed Esmeraldas to Esmeraldas Province
    ('2923', 'Azuay Province', '64'),
    ('2924', 'El Oro Province', '64'),
    ('2925', 'Chimborazo Province', '64'),
    ('2926', 'Orellana Province', '64'),
    ('2927', 'Pichincha Province', '64'),
    ('2928', 'Obock Region', '60'),
    ('2929', 'Djibouti Region', '60'), -- Changed Djibouti to Djibouti Region (includes the city)
    ('2930', 'Dikhil Region', '60'),
    ('2931', 'Tadjourah Region', '60'),
    ('2932', 'Arta Region', '60'),
    ('2933', 'Ali Sabieh Region', '60'),
    ('2934', 'Hama Governorate', '215'),
    ('2935', 'Rif Dimashq Governorate', '215'), -- Rural Damascus
    ('2936', 'As-Suwayda Governorate', '215'),
    ('2937', 'Deir ez-Zor Governorate', '215'),
    ('2938', 'Latakia Governorate', '215'),
    ('2939', 'Damascus Governorate', '215'), -- Capital Governorate
    ('2940', 'Idlib Governorate', '215'),
    ('2941', 'Al-Hasakah Governorate', '215'),
    ('2942', 'Homs Governorate', '215'),
    ('2943', 'Quneitra Governorate', '215'), -- Largely Israeli-occupied Golan Heights
    ('2944', 'Al-Raqqah Governorate', '215'), -- Raqqa
    ('2945', 'Daraa Governorate', '215'),
    ('2946', 'Aleppo Governorate', '215'),
    ('2947', 'Tartus Governorate', '215'),
    (
        '2948',
        'Fianarantsoa Province (historical)',
        '130'
    ), -- Province abolished 2009, Added (historical)
    ('2949', 'Toliara Province (historical)', '130'), -- Province abolished 2009, Added (historical)
    (
        '2950',
        'Antsiranana Province (historical)',
        '130'
    ), -- Province abolished 2009, Added (historical)
    (
        '2951',
        'Antananarivo Province (historical)',
        '130'
    ), -- Province abolished 2009, Added (historical)
    ('2952', 'Toamasina Province (historical)', '130'), -- Province abolished 2009, Added (historical)
    ('2953', 'Mahajanga Province (historical)', '130'), -- Province abolished 2009, Added (historical)
    ('2954', 'Mogilev Region', '21'), -- Voblast
    ('2955', 'Gomel Region', '21'), -- Voblast (Homiel)
    ('2956', 'Grodno Region', '21'), -- Voblast (Hrodna)
    ('2957', 'Minsk Region', '21'), -- Voblast
    ('2958', 'Minsk City', '21'), -- Changed Minsk to Minsk City (Capital City / Voblast)
    ('2959', 'Brest Region', '21'), -- Voblast
    ('2960', 'Vitebsk Region', '21'), -- Voblast (Viciebsk)
    ('2961', 'Murqub District', '124'), -- Changed Murqub to Murqub District (Sha'biyah - pre-2007 boundary?)
    ('2962', 'Nuqat al Khams District', '124'), -- Changed Nuqat al Khams to Nuqat al Khams District (Sha'biyah)
    ('2963', 'Zawiya District', '124'), -- Az Zawiyah (Sha'biyah)
    ('2964', 'Al Wahat District', '124'), -- Al Wāḥāt (Sha'biyah)
    ('2965', 'Sabha District', '124'), -- (Sha'biyah)
    ('2966', 'Derna District', '124'), -- Darnah (Sha'biyah)
    ('2967', 'Murzuq District', '124'), -- Murzuq (Sha'biyah)
    ('2968', 'Marj District', '124'), -- Al Marj (Sha'biyah)
    ('2969', 'Ghat District', '124'), -- Ghāt (Sha'biyah)
    ('2970', 'Jufra District', '124'), -- Changed Jufra to Jufra District (Al Jufrah - Sha'biyah)
    ('2971', 'Tripoli District', '124'), -- Ṭarābulus (Sha'biyah - Capital)
    ('2972', 'Kufra District', '124'), -- Al Kufrah (Sha'biyah)
    ('2973', 'Wadi al Hayaa District', '124'), -- Wādī al Ḩayāt (Sha'biyah)
    ('2974', 'Jabal al Gharbi District', '124'), -- Al Jabal al Gharbī (Sha'biyah)
    ('2975', 'Wadi al Shatii District', '124'), -- Wādī ash Shāţiʾ (Sha'biyah)
    ('2976', 'Nalut District', '124'), -- Nālūt (Sha'biyah)
    ('2977', 'Sirte District', '124'), -- Surt (Sha'biyah)
    ('2978', 'Misrata District', '124'), -- Miṣrātah (Sha'biyah)
    ('2979', 'Jafara District', '124'), -- Changed Jafara to Jafara District (Al Jifārah - Sha'biyah)
    ('2980', 'Jabal al Akhdar District', '124'), -- Changed Jabal al Akhdar to Jabal al Akhdar District (Sha'biyah)
    ('2981', 'Benghazi District', '124'), -- Changed Benghazi to Benghazi District (Banghāzī - Sha'biyah)
    ('2982', 'Ribeira Brava Municipality', '40'), -- Concelho
    ('2983', 'Tarrafal Municipality', '40'), -- Changed Tarrafal to Tarrafal Municipality (Concelho, Santiago Island)
    (
        '2984',
        'Ribeira Grande de Santiago Municipality',
        '40'
    ), -- Concelho
    ('2985', 'Santa Catarina Municipality', '40'), -- Concelho (Santiago Island)
    ('2986', 'São Domingos Municipality', '40'), -- São Domingos has 'ã' (Concelho)
    ('2987', 'Mosteiros Municipality', '40'), -- Concelho
    ('2988', 'Praia Municipality', '40'), -- Concelho (Capital)
    ('2989', 'Porto Novo Municipality', '40'), -- Concelho
    ('2990', 'São Miguel Municipality', '40'), -- São Miguel has 'ã' (Concelho)
    ('2991', 'Maio Municipality', '40'), -- Concelho
    ('2992', 'Sotavento Islands', '40'), -- Island group (geographic, not administrative) - Consider removing
    (
        '2993',
        'São Lourenço dos Órgãos Municipality',
        '40'
    ), -- São Lourenço has 'ç', Órgãos has 'Ó' (Concelho)
    ('2994', 'Barlavento Islands', '40'), -- Island group (geographic, not administrative) - Consider removing
    (
        '2995',
        'Santa Catarina do Fogo Municipality',
        '40'
    ), -- Concelho
    ('2996', 'Brava Municipality', '40'), -- Changed Brava to Brava Municipality (Concelho)
    ('2997', 'Paul Municipality', '40'), -- Changed Paul to Paul Municipality (Paúl - Concelho), Paúl has 'ú'
    ('2998', 'Sal Municipality', '40'), -- Changed Sal to Sal Municipality (Concelho)
    ('2999', 'Boa Vista Municipality', '40'), -- Changed Boa Vista to Boa Vista Municipality (Concelho)
    ('3000', 'São Filipe Municipality', '40'), -- São Filipe has 'ã' (Concelho)
    ('3001', 'São Vicente Municipality', '40'), -- São Vicente has 'ã' (Concelho)
    ('3002', 'Ribeira Grande Municipality', '40'), -- Concelho (Santo Antão Island)
    (
        '3003',
        'Tarrafal de São Nicolau Municipality',
        '40'
    ), -- São Nicolau has 'ã' (Concelho)
    ('3004', 'Santa Cruz Municipality', '40'), -- Concelho (Santiago Island)
    ('3005', 'Schleswig-Holstein', '82'), -- State (Land)
    ('3006', 'Baden-Württemberg', '82'), -- State (Land)
    ('3007', 'Mecklenburg-Vorpommern', '82'), -- State (Land)
    ('3008', 'Lower Saxony', '82'), -- Niedersachsen (State - Land)
    ('3009', 'Bavaria', '82'), -- Bayern (State - Land)
    ('3010', 'Berlin', '82'), -- State / City (Land)
    ('3011', 'Saxony-Anhalt', '82'), -- Sachsen-Anhalt (State - Land)
    ('3013', 'Brandenburg', '82'), -- State (Land) (Missing ID 3012?)
    ('3014', 'Bremen', '82'), -- Free Hanseatic City of Bremen (State - Land)
    ('3015', 'Thuringia', '82'), -- Thüringen (State - Land)
    ('3016', 'Hamburg', '82'), -- Free and Hanseatic City of Hamburg (State - Land)
    ('3017', 'North Rhine-Westphalia', '82'), -- Nordrhein-Westfalen (State - Land)
    ('3018', 'Hesse', '82'), -- Hessen (State - Land)
    ('3019', 'Rhineland-Palatinate', '82'), -- Rheinland-Pfalz (State - Land)
    ('3020', 'Saarland', '82'), -- State (Land)
    ('3021', 'Saxony', '82'), -- Sachsen (State - Land)
    ('3022', 'Mafeteng District', '122'),
    ('3023', 'Mohale''s Hoek District', '122'), -- Fixed escaping
    ('3024', 'Mokhotlong District', '122'),
    ('3025', 'Qacha''s Nek District', '122'), -- Fixed escaping
    ('3026', 'Leribe District', '122'),
    ('3027', 'Quthing District', '122'),
    ('3028', 'Maseru District', '122'),
    ('3029', 'Butha-Buthe District', '122'),
    ('3030', 'Berea District', '122'),
    ('3031', 'Thaba-Tseka District', '122'),
    ('3032', 'Montserrado County', '123'),
    ('3033', 'River Cess County', '123'),
    ('3034', 'Bong County', '123'),
    ('3035', 'Sinoe County', '123'),
    ('3036', 'Grand Cape Mount County', '123'),
    ('3037', 'Lofa County', '123'),
    ('3038', 'River Gee County', '123'),
    ('3039', 'Grand Gedeh County', '123'),
    ('3040', 'Grand Bassa County', '123'),
    ('3041', 'Bomi County', '123'),
    ('3042', 'Maryland County', '123'),
    ('3043', 'Margibi County', '123'),
    ('3044', 'Gbarpolu County', '123'),
    ('3045', 'Grand Kru County', '123'),
    ('3046', 'Nimba County', '123'), -- Changed Nimba to Nimba County
    ('3047', 'Ad Dhahirah Governorate', '166'), -- Az̧ Z̧āhirah
    ('3048', 'Al Batinah North Governorate', '166'), -- Shamāl al Bāţinah
    ('3049', 'Al Batinah South Governorate', '166'), -- Janūb al Bāţinah
    ('3050', 'Al Batinah Region (historical)', '166'), -- Abolished 2011, split into North/South. Added (historical).
    (
        '3051',
        'Ash Sharqiyah Region (historical)',
        '166'
    ), -- Abolished 2011, split into North/South. Added (historical).
    ('3052', 'Musandam Governorate', '166'),
    ('3053', 'Ash Sharqiyah North Governorate', '166'), -- Shamāl ash Sharqīyah
    ('3054', 'Ash Sharqiyah South Governorate', '166'), -- Janūb ash Sharqīyah
    ('3055', 'Muscat Governorate', '166'),
    ('3056', 'Al Wusta Governorate', '166'), -- Al Wusţá
    ('3057', 'Dhofar Governorate', '166'), -- Z̧ufār
    ('3058', 'Ad Dakhiliyah Governorate', '166'), -- Ad Dākhilīyah
    ('3059', 'Al Buraimi Governorate', '166'), -- Al Buraymī
    ('3060', 'Ngamiland District (historical)', '29'), -- Changed Ngamiland to Ngamiland District (historical). Merged into North-West District.
    ('3061', 'Ghanzi District', '29'),
    ('3062', 'Kgatleng District', '29'),
    ('3063', 'Southern District', '29'),
    ('3064', 'South-East District', '29'),
    ('3065', 'North-West District', '29'),
    ('3066', 'Kgalagadi District', '29'),
    ('3067', 'Central District', '29'),
    ('3068', 'North-East District', '29'),
    ('3069', 'Kweneng District', '29'),
    ('3070', 'Collines Department', '24'),
    ('3071', 'Kouffo Department', '24'),
    ('3072', 'Donga Department', '24'),
    ('3073', 'Zou Department', '24'),
    ('3074', 'Plateau Department', '24'),
    ('3075', 'Mono Department', '24'),
    ('3076', 'Atakora Department', '24'),
    ('3077', 'Alibori Department', '24'),
    ('3078', 'Borgou Department', '24'),
    ('3079', 'Atlantique Department', '24'),
    ('3080', 'Ouémé Department', '24'), -- Ouémé has 'é'
    ('3081', 'Littoral Department', '24'),
    ('3082', 'Machinga District', '131'),
    ('3083', 'Zomba District', '131'),
    ('3084', 'Mwanza District', '131'),
    ('3085', 'Nsanje District', '131'),
    ('3086', 'Salima District', '131'),
    ('3087', 'Chitipa District', '131'), -- Changed Chitipa district to Chitipa District
    ('3088', 'Ntcheu District', '131'),
    ('3089', 'Rumphi District', '131'),
    ('3090', 'Dowa District', '131'),
    ('3091', 'Karonga District', '131'),
    ('3092', 'Central Region', '131'),
    ('3093', 'Likoma District', '131'),
    ('3094', 'Kasungu District', '131'),
    ('3095', 'Nkhata Bay District', '131'),
    ('3096', 'Balaka District', '131'),
    ('3097', 'Dedza District', '131'),
    ('3098', 'Thyolo District', '131'),
    ('3099', 'Mchinji District', '131'),
    ('3100', 'Nkhotakota District', '131'),
    ('3101', 'Lilongwe District', '131'),
    ('3102', 'Blantyre District', '131'),
    ('3103', 'Mulanje District', '131'),
    ('3104', 'Mzimba District', '131'),
    ('3105', 'Northern Region', '131'),
    ('3106', 'Southern Region', '131'),
    ('3107', 'Chikwawa District', '131'),
    ('3108', 'Phalombe District', '131'),
    ('3109', 'Chiradzulu District', '131'),
    ('3110', 'Mangochi District', '131'),
    ('3111', 'Ntchisi District', '131'),
    ('3112', 'Kénédougou Province', '35'), -- Kénédougou has 'é'
    ('3113', 'Namentenga Province', '35'),
    ('3114', 'Sahel Region', '35'),
    ('3115', 'Centre-Ouest Region', '35'), -- Centre-West
    ('3116', 'Nahouri Province', '35'),
    ('3117', 'Passoré Province', '35'), -- Passoré has 'é'
    ('3118', 'Zoundwéogo Province', '35'), -- Zoundwéogo has 'é'
    ('3119', 'Sissili Province', '35'),
    ('3120', 'Banwa Province', '35'),
    ('3121', 'Bougouriba Province', '35'),
    ('3122', 'Gnagna Province', '35'),
    ('3123', 'Mouhoun Province', '35'), -- Changed Mouhoun to Mouhoun Province
    ('3124', 'Yagha Province', '35'),
    ('3125', 'Plateau-Central Region', '35'),
    ('3126', 'Sanmatenga Province', '35'),
    ('3127', 'Centre-Nord Region', '35'), -- Centre-North
    ('3128', 'Tapoa Province', '35'),
    ('3129', 'Houet Province', '35'),
    ('3130', 'Zondoma Province', '35'),
    ('3131', 'Boulgou Province', '35'), -- Changed Boulgou to Boulgou Province
    ('3132', 'Komondjari Province', '35'),
    ('3133', 'Koulpélogo Province', '35'), -- Koulpélogo has 'é'
    ('3134', 'Tuy Province', '35'),
    ('3135', 'Ioba Province', '35'),
    ('3136', 'Centre Region', '35'), -- Changed Centre to Centre Region
    ('3137', 'Sourou Province', '35'),
    ('3138', 'Boucle du Mouhoun Region', '35'),
    ('3139', 'Séno Province', '35'), -- Séno has 'é'
    ('3140', 'Sud-Ouest Region', '35'), -- South-West
    ('3141', 'Oubritenga Province', '35'),
    ('3142', 'Nayala Province', '35'),
    ('3143', 'Gourma Province', '35'),
    ('3144', 'Oudalan Province', '35'),
    ('3145', 'Ziro Province', '35'),
    ('3146', 'Kossi Province', '35'),
    ('3147', 'Kourwéogo Province', '35'), -- Kourwéogo has 'é'
    ('3148', 'Ganzourgou Province', '35'),
    ('3149', 'Centre-Sud Region', '35'), -- Centre-South
    ('3150', 'Yatenga Province', '35'),
    ('3151', 'Loroum Province', '35'),
    ('3152', 'Bazèga Province', '35'), -- Bazèga has 'è'
    ('3153', 'Cascades Region', '35'),
    ('3154', 'Sanguié Province', '35'), -- Sanguié has 'é'
    ('3155', 'Bam Province', '35'),
    ('3156', 'Noumbiel Province', '35'),
    ('3157', 'Kompienga Province', '35'),
    ('3158', 'Est Region', '35'), -- East
    ('3159', 'Léraba Province', '35'), -- Léraba has 'é'
    ('3160', 'Balé Province', '35'), -- Balé has 'é'
    ('3161', 'Kouritenga Province', '35'),
    ('3162', 'Centre-Est Region', '35'), -- Centre-East
    ('3163', 'Poni Province', '35'),
    ('3164', 'Nord Region', '35'), -- Changed Nord Region, Burkina Faso to Nord Region
    ('3165', 'Hauts-Bassins Region', '35'),
    ('3166', 'Soum Province', '35'),
    ('3167', 'Comoé Province', '35'), -- Comoé has 'é'
    ('3168', 'Kadiogo Province', '35'),
    ('3169', 'Islamabad Capital Territory', '167'),
    ('3170', 'Gilgit-Baltistan', '167'), -- Autonomous Territory
    ('3171', 'Khyber Pakhtunkhwa', '167'), -- Province
    ('3172', 'Azad Jammu and Kashmir', '167'), -- Changed Azad Kashmir to Azad Jammu and Kashmir (Autonomous Territory)
    (
        '3173',
        'Federally Administered Tribal Areas (historical)',
        '167'
    ), -- Merged into Khyber Pakhtunkhwa in 2018. Added (historical).
    ('3174', 'Balochistan', '167'), -- Province
    ('3175', 'Sindh', '167'), -- Province
    ('3176', 'Punjab', '167'), -- Province
    ('3177', 'Al Rayyan Municipality', '179'), -- Ar Rayyān
    ('3178', 'Al Shamal Municipality', '179'), -- Changed Al-Shahaniya to Al Shamal Municipality (Ash Shamāl - Al-Shahaniya became separate in 2014, assuming this refers to Ash Shamal)
    ('3179', 'Al Wakrah Municipality', '179'), -- Changed Al Wakrah to Al Wakrah Municipality (Al Wakrah)
    ('3180', 'Madinat ash Shamal', '179'), -- This is the capital city of Al Shamal Municipality (ID 3178). May be redundant.
    ('3181', 'Doha Municipality', '179'), -- Changed Doha to Doha Municipality (Ad Dawḩah)
    ('3182', 'Al Daayen Municipality', '179'), -- Az̧ Za̧`āyin
    ('3183', 'Al Khor Municipality', '179'), -- Changed Al Khor to Al Khor Municipality (Al Khawr wa adh Dhakhīrah)
    ('3184', 'Umm Salal Municipality', '179'), -- Umm Şalāl
    ('3185', 'Rumonge Province', '36'),
    ('3186', 'Muyinga Province', '36'),
    ('3187', 'Mwaro Province', '36'),
    ('3188', 'Makamba Province', '36'),
    ('3189', 'Rutana Province', '36'),
    ('3190', 'Cibitoke Province', '36'),
    ('3191', 'Ruyigi Province', '36'),
    ('3192', 'Kayanza Province', '36'),
    ('3193', 'Muramvya Province', '36'),
    ('3194', 'Karuzi Province', '36'),
    ('3195', 'Kirundo Province', '36'),
    ('3196', 'Bubanza Province', '36'),
    ('3197', 'Gitega Province', '36'),
    ('3198', 'Bujumbura Mairie Province', '36'), -- (Capital City)
    ('3199', 'Ngozi Province', '36'),
    ('3200', 'Bujumbura Rural Province', '36'),
    ('3201', 'Cankuzo Province', '36'),
    ('3202', 'Bururi Province', '36'),
    ('3203', 'Flores Department', '235'),
    ('3204', 'San José Department', '235'), -- San José has 'é'
    ('3205', 'Artigas Department', '235'),
    ('3206', 'Maldonado Department', '235'),
    ('3207', 'Rivera Department', '235'),
    ('3208', 'Colonia Department', '235'),
    ('3209', 'Durazno Department', '235'),
    ('3210', 'Río Negro Department', '235'), -- Río has 'í'
    ('3211', 'Cerro Largo Department', '235'),
    ('3212', 'Paysandú Department', '235'), -- Paysandú has 'ú'
    ('3213', 'Canelones Department', '235'),
    ('3214', 'Treinta y Tres Department', '235'),
    ('3215', 'Lavalleja Department', '235'),
    ('3216', 'Rocha Department', '235'),
    ('3217', 'Florida Department', '235'),
    ('3218', 'Montevideo Department', '235'), -- (Capital)
    ('3219', 'Soriano Department', '235'),
    ('3220', 'Salto Department', '235'),
    ('3221', 'Tacuarembó Department', '235'), -- Tacuarembó has 'ó'
    ('3222', 'Kafr el-Sheikh Governorate', '65'),
    ('3223', 'Cairo Governorate', '65'),
    ('3224', 'Damietta Governorate', '65'),
    ('3225', 'Aswan Governorate', '65'),
    ('3226', 'Sohag Governorate', '65'),
    ('3227', 'North Sinai Governorate', '65'),
    ('3228', 'Monufia Governorate', '65'), -- Menoufia
    ('3229', 'Port Said Governorate', '65'),
    ('3230', 'Beni Suef Governorate', '65'),
    ('3231', 'Matrouh Governorate', '65'), -- Matruh
    ('3232', 'Qalyubia Governorate', '65'),
    ('3233', 'Suez Governorate', '65'),
    ('3234', 'Gharbia Governorate', '65'),
    ('3235', 'Alexandria Governorate', '65'),
    ('3236', 'Asyut Governorate', '65'),
    ('3237', 'South Sinai Governorate', '65'),
    ('3238', 'Faiyum Governorate', '65'), -- Fayoum
    ('3239', 'Giza Governorate', '65'),
    ('3240', 'Red Sea Governorate', '65'),
    ('3241', 'Beheira Governorate', '65'), -- El Beheira
    ('3242', 'Luxor Governorate', '65'),
    ('3243', 'Minya Governorate', '65'),
    ('3244', 'Ismailia Governorate', '65'),
    ('3245', 'Dakahlia Governorate', '65'), -- Ad Daqahliyah
    ('3246', 'New Valley Governorate', '65'), -- Al Wadi al Jadid
    ('3247', 'Qena Governorate', '65'),
    ('3248', 'Agaléga', '140'), -- Outer island of Mauritius, Agaléga has 'é'
    ('3249', 'Rodrigues', '140'), -- Outer island of Mauritius (Autonomous)
    ('3250', 'Pamplemousses District', '140'),
    (
        '3251',
        'Saint Brandon (Cargados Carajos Shoals)',
        '140'
    ), -- Changed Cargados Carajos to Saint Brandon (Cargados Carajos Shoals) (Outer islands of Mauritius)
    ('3252', 'Vacoas-Phoenix', '140'), -- Town / Municipality
    ('3253', 'Moka District', '140'),
    ('3254', 'Flacq District', '140'),
    ('3255', 'Curepipe', '140'), -- Town / Municipality
    ('3256', 'Port Louis City', '140'), -- Changed Port Louis to Port Louis City (Capital City)
    ('3257', 'Savanne District', '140'),
    ('3258', 'Quatre Bornes', '140'), -- Town / Municipality
    ('3259', 'Rivière Noire District', '140'), -- Rivière has 'è' (Black River District)
    ('3260', 'Port Louis District', '140'), -- (District surrounding the city)
    ('3261', 'Rivière du Rempart District', '140'), -- Rivière has 'è'
    ('3262', 'Beau Bassin-Rose Hill', '140'), -- Town / Municipality
    ('3263', 'Plaines Wilhems District', '140'),
    ('3264', 'Grand Port District', '140'),
    ('3265', 'Guelmim Province (historical)', '149'), -- Part of Guelmim-Oued Noun region, province structure changed. Added (historical).
    ('3266', 'Aousserd Province', '149'), -- Part of Dakhla-Oued Ed-Dahab region (Western Sahara)
    ('3267', 'Al Hoceïma Province', '149'), -- Al Hoceïma has 'ï'. Part of Tanger-Tétouan-Al Hoceïma region.
    ('3268', 'Larache Province', '149'), -- Part of Tanger-Tétouan-Al Hoceïma region.
    ('3269', 'Ouarzazate Province', '149'), -- Part of Drâa-Tafilalet region.
    ('3270', 'Boulemane Province', '149'), -- Part of Fès-Meknès region.
    ('3271', 'Oriental Region', '149'), -- Changed Oriental to Oriental Region (Region)
    ('3272', 'Béni-Mellal Province', '149'), -- Béni-Mellal has 'é'. Part of Béni Mellal-Khénifra region.
    ('3273', 'Marrakesh Prefecture', '149'), -- Changed Sidi Youssef Ben Ali to Marrakesh Prefecture (Prefecture in Marrakesh-Safi region)
    ('3274', 'Chichaoua Province', '149'), -- Part of Marrakesh-Safi region.
    ('3275', 'Boujdour Province', '149'), -- Part of Laâyoune-Sakia El Hamra region (Western Sahara)
    ('3276', 'Khémisset Province', '149'), -- Khémisset has 'é'. Part of Rabat-Salé-Kénitra region.
    ('3277', 'Tiznit Province', '149'), -- Part of Souss-Massa region.
    ('3278', 'Béni Mellal-Khénifra', '149'), -- Béni Mellal has 'é', Khénifra has 'é'. (Region)
    ('3279', 'Sidi Kacem Province', '149'), -- Part of Rabat-Salé-Kénitra region.
    ('3280', 'El Jadida Province', '149'), -- Part of Casablanca-Settat region.
    ('3281', 'Nador Province', '149'), -- Part of Oriental region.
    ('3282', 'Settat Province', '149'), -- Part of Casablanca-Settat region.
    ('3283', 'Zagora Province', '149'), -- Part of Drâa-Tafilalet region.
    ('3284', 'Médiouna Province', '149'), -- Médiouna has 'é'. Part of Casablanca-Settat region.
    ('3285', 'Berkane Province', '149'), -- Part of Oriental region.
    ('3286', 'Tan-Tan Province', '149'), -- Part of Guelmim-Oued Noun region.
    ('3287', 'Nouaceur Province', '149'), -- Part of Casablanca-Settat region.
    ('3288', 'Marrakesh-Safi', '149'), -- Region
    ('3289', 'Sefrou Province', '149'), -- Part of Fès-Meknès region.
    ('3290', 'Drâa-Tafilalet', '149'), -- Drâa has 'â'. (Region)
    ('3291', 'El Hajeb Province', '149'), -- Part of Fès-Meknès region.
    ('3292', 'Es Semara Province', '149'), -- Part of Guelmim-Oued Noun / Laâyoune-Sakia El Hamra regions (Western Sahara). Es Semara / Smara.
    ('3293', 'Laâyoune Province', '149'), -- Laâyoune has 'â'. Part of Laâyoune-Sakia El Hamra region (Western Sahara).
    ('3294', 'Inezgane-Aït Melloul Prefecture', '149'), -- Aït has 'ï'. Part of Souss-Massa region.
    ('3295', 'Souss-Massa', '149'), -- Region
    ('3296', 'Taza Province', '149'), -- Part of Fès-Meknès region.
    ('3297', 'Assa-Zag Province', '149'), -- Part of Guelmim-Oued Noun region.
    ('3298', 'Laâyoune-Sakia El Hamra', '149'), -- Laâyoune has 'â'. (Region - includes Western Sahara territory)
    ('3299', 'Errachidia Province', '149'), -- Part of Drâa-Tafilalet region.
    ('3300', 'Fahs-Anjra Province', '149'), -- Part of Tanger-Tétouan-Al Hoceïma region.
    ('3301', 'Figuig Province', '149'), -- Part of Oriental region.
    ('3302', 'Chtouka-Aït Baha Province', '149'), -- Chtouka / Aït has 'ï'. Part of Souss-Massa region.
    ('3303', 'Casablanca-Settat', '149'), -- Region
    ('3304', 'Benslimane Province', '149'), -- Changed Ben Slimane to Benslimane. Part of Casablanca-Settat region.
    ('3305', 'Guelmim-Oued Noun', '149'), -- Region
    ('3306', 'Dakhla-Oued Ed-Dahab', '149'), -- Region (entirely Western Sahara)
    ('3307', 'Jerada Province', '149'), -- Part of Oriental region.
    ('3308', 'Kénitra Province', '149'), -- Kénitra has 'é'. Part of Rabat-Salé-Kénitra region.
    ('3309', 'El Kelâa des Sraghna Province', '149'), -- Changed Kelaat Sraghna to El Kelâa des Sraghna. Kelâa has 'â'. Part of Marrakesh-Safi region.
    ('3310', 'Chefchaouen Province', '149'), -- Part of Tanger-Tétouan-Al Hoceïma region.
    ('3311', 'Safi Province', '149'), -- Part of Marrakesh-Safi region.
    ('3312', 'Tata Province', '149'), -- Part of Souss-Massa region.
    ('3313', 'Fès-Meknès', '149'), -- Fès has 'è', Meknès has 'è'. (Region)
    ('3314', 'Taroudant Province', '149'), -- Part of Souss-Massa region.
    ('3315', 'Moulay Yacoub Province', '149'), -- Part of Fès-Meknès region.
    ('3316', 'Essaouira Province', '149'), -- Part of Marrakesh-Safi region.
    ('3317', 'Khénifra Province', '149'), -- Khénifra has 'é'. Part of Béni Mellal-Khénifra region.
    ('3318', 'Tétouan Province', '149'), -- Tétouan has 'é'. Part of Tanger-Tétouan-Al Hoceïma region.
    (
        '3319',
        'Oued Ed-Dahab Province (historical)',
        '149'
    ), -- Replaced by Aousserd and Oued Ed-Dahab provinces within Dakhla-Oued Ed-Dahab region. Added (historical).
    ('3320', 'Al Haouz Province', '149'), -- Part of Marrakesh-Safi region.
    ('3321', 'Azilal Province', '149'), -- Part of Béni Mellal-Khénifra region.
    ('3322', 'Taourirt Province', '149'), -- Part of Oriental region.
    ('3323', 'Taounate Province', '149'), -- Part of Fès-Meknès region.
    ('3324', 'Tanger-Tétouan-Al Hoceïma', '149'), -- Tanger / Tétouan has 'é', Hoceïma has 'ï'. (Region)
    ('3325', 'Ifrane Province', '149'), -- Part of Fès-Meknès region.
    ('3326', 'Khouribga Province', '149'), -- Part of Béni Mellal-Khénifra region.
    ('3327', 'Cabo Delgado Province', '150'),
    ('3328', 'Zambezia Province', '150'), -- Zambézia has 'é'
    ('3329', 'Gaza Province', '150'),
    ('3330', 'Inhambane Province', '150'),
    ('3331', 'Sofala Province', '150'),
    ('3332', 'Maputo Province', '150'),
    ('3333', 'Niassa Province', '150'),
    ('3334', 'Tete Province', '150'),
    ('3335', 'Maputo City', '150'), -- Changed Maputo to Maputo City (Capital City with province status)
    ('3336', 'Nampula Province', '150'),
    ('3337', 'Manica Province', '150'),
    ('3338', 'Hodh Ech Chargui Region', '139'), -- Wilayah
    ('3339', 'Brakna Region', '139'), -- Wilayah
    ('3340', 'Tiris Zemmour Region', '139'), -- Wilayah
    ('3341', 'Gorgol Region', '139'), -- Wilayah
    ('3342', 'Inchiri Region', '139'), -- Wilayah
    ('3343', 'Nouakchott-Nord Region', '139'), -- Wilayah (Part of Nouakchott Capital Region)
    ('3344', 'Adrar Region', '139'), -- Wilayah
    ('3345', 'Tagant Region', '139'), -- Wilayah
    ('3346', 'Dakhlet Nouadhibou Region', '139'), -- Changed Dakhlet Nouadhibou to Dakhlet Nouadhibou Region (Wilayah)
    ('3347', 'Nouakchott-Sud Region', '139'), -- Wilayah (Part of Nouakchott Capital Region)
    ('3348', 'Trarza Region', '139'), -- Wilayah
    ('3349', 'Assaba Region', '139'), -- Wilayah ('Aşşābah)
    ('3350', 'Guidimaka Region', '139'), -- Wilayah (Guidimagha)
    ('3351', 'Hodh El Gharbi Region', '139'), -- Wilayah
    ('3352', 'Nouakchott-Ouest Region', '139'), -- Wilayah (Part of Nouakchott Capital Region)
    ('3353', 'Tobago', '223'), -- Changed Western Tobago to Tobago (Autonomous Island - administrative division)
    (
        '3354',
        'Couva-Tabaquite-Talparo Regional Corporation',
        '223'
    ),
    ('3355', 'Tobago', '223'), -- Duplicate of 3353, Eastern Tobago is not a separate official division. Removing 'Eastern'. Consider removing duplicate.
    (
        '3356',
        'Rio Claro-Mayaro Regional Corporation',
        '223'
    ),
    (
        '3357',
        'San Juan-Laventille Regional Corporation',
        '223'
    ),
    (
        '3358',
        'Tunapuna-Piarco Regional Corporation',
        '223'
    ),
    ('3359', 'San Fernando', '223'), -- City Corporation
    ('3360', 'Point Fortin', '223'), -- Borough Corporation
    (
        '3361',
        'Sangre Grande Regional Corporation',
        '223'
    ),
    ('3362', 'Arima', '223'), -- Borough Corporation
    ('3363', 'Port of Spain', '223'), -- City Corporation (Capital)
    ('3364', 'Siparia Regional Corporation', '223'),
    ('3365', 'Penal-Debe Regional Corporation', '223'), -- Penal-Dēbē, Dēbē has 'ē'
    ('3366', 'Chaguanas', '223'), -- Borough Corporation
    (
        '3367',
        'Diego Martin Regional Corporation',
        '223'
    ),
    (
        '3368',
        'Princes Town Regional Corporation',
        '223'
    ),
    ('3369', 'Mary Region', '226'), -- Welayat
    ('3370', 'Lebap Region', '226'), -- Welayat
    ('3371', 'Ashgabat City', '226'), -- Changed Ashgabat to Ashgabat City (Capital City with welayat status)
    ('3372', 'Balkan Region', '226'), -- Welayat
    ('3373', 'Daşoguz Region', '226'), -- Daşoguz has 'ş' (Welayat)
    ('3374', 'Ahal Region', '226'), -- Welayat
    ('3375', 'Beni Department', '27'),
    ('3376', 'Oruro Department', '27'),
    ('3377', 'Santa Cruz Department', '27'),
    ('3378', 'Tarija Department', '27'),
    ('3379', 'Pando Department', '27'),
    ('3380', 'La Paz Department', '27'),
    ('3381', 'Cochabamba Department', '27'),
    ('3382', 'Chuquisaca Department', '27'),
    ('3383', 'Potosí Department', '27'), -- Potosí has 'í'
    ('3384', 'Saint George Parish', '188'), -- Saint Vincent and the Grenadines
    ('3385', 'Saint Patrick Parish', '188'),
    ('3386', 'Saint Andrew Parish', '188'),
    ('3387', 'Saint David Parish', '188'),
    ('3388', 'Grenadines Parish', '188'),
    ('3389', 'Charlotte Parish', '188'),
    ('3390', 'Sharjah Emirate', '231'), -- Ash Shāriqah
    ('3391', 'Dubai Emirate', '231'), -- Changed Dubai to Dubai Emirate (Dubayy)
    ('3392', 'Umm al-Quwain Emirate', '231'), -- Changed Umm al-Quwain to Umm al-Quwain Emirate (Umm al Qaywayn)
    ('3393', 'Fujairah Emirate', '231'), -- Changed Fujairah to Fujairah Emirate (Al Fujayrah)
    ('3394', 'Ras al-Khaimah Emirate', '231'), -- Ra’s al Khaymah
    ('3395', 'Ajman Emirate', '231'), -- ‘Ajmān
    ('3396', 'Abu Dhabi Emirate', '231'), -- Abū Z̧aby
    (
        '3397',
        'Districts of Republican Subordination',
        '217'
    ), -- Region
    ('3398', 'Khatlon Province', '217'), -- Viloyat
    (
        '3399',
        'Gorno-Badakhshan Autonomous Province',
        '217'
    ), -- Viloyati Mukhtori Kūhistoni Badakhshon
    ('3400', 'Sughd Province', '217'), -- Viloyat
    ('3401', 'Tainan County (historical)', '216'), -- Merged into Tainan City 2010. Added (historical). Note: Taiwan listed under PRC country ID 45 earlier. This entry is for Taiwan (ROC). Need consistent country ID. Assuming 216 is ROC.
    ('3402', 'Yilan County', '216'),
    ('3403', 'Penghu County', '216'),
    ('3404', 'Changhua County', '216'),
    ('3405', 'Pingtung County', '216'),
    ('3406', 'Taichung City', '216'), -- Changed Taichung to Taichung City (Special Municipality, merged with county)
    ('3407', 'Nantou County', '216'),
    ('3408', 'Chiayi County', '216'),
    ('3409', 'Kaohsiung County (historical)', '216'), -- Merged into Kaohsiung City 2010. Added (historical).
    ('3410', 'Taitung County', '216'),
    ('3411', 'Hualien County', '216'),
    ('3412', 'Kaohsiung City', '216'), -- Changed Kaohsiung to Kaohsiung City (Special Municipality, merged with county)
    ('3413', 'Miaoli County', '216'),
    ('3414', 'Taichung County (historical)', '216'), -- Merged into Taichung City 2010. Added (historical).
    ('3415', 'Kinmen County', '216'), -- Changed Kinmen to Kinmen County (Fuchien Province)
    ('3416', 'Yunlin County', '216'),
    ('3417', 'Hsinchu City', '216'), -- Changed Hsinchu to Hsinchu City (Provincial City)
    ('3418', 'Chiayi City', '216'), -- (Provincial City)
    ('3419', 'Taoyuan City', '216'), -- (Special Municipality since 2014)
    ('3420', 'Lienchiang County', '216'), -- (Matsu Islands, Fuchien Province)
    ('3421', 'Tainan City', '216'), -- Changed Tainan to Tainan City (Special Municipality, merged with county)
    ('3422', 'Taipei City', '216'), -- Changed Taipei to Taipei City (Special Municipality - Capital)
    ('3423', 'Hsinchu County', '216'),
    ('3424', 'Northern Red Sea Region', '68'), -- Semēnawī K’eyih Bahrī
    ('3425', 'Anseba Region', '68'),
    ('3426', 'Maekel Region', '68'), -- Central Region (Ma''ākel)
    ('3427', 'Debub Region', '68'), -- Southern Region (Debubawī)
    ('3428', 'Gash-Barka Region', '68'),
    ('3429', 'Southern Red Sea Region', '68'), -- Debubawī K’eyih Bahrī
    ('3430', 'Westfjords Region', '100'), -- Changed Southern Peninsula Region to Westfjords Region (Vestfirðir). Southern Peninsula is ID 3434 Reykjanesbær / Suðurnes. Seems ID/Name mismatch. Corrected name for ID 3430.
    ('3431', 'Capital Region', '100'), -- Höfuðborgarsvæðið
    ('3432', 'Westfjords Region', '100'), -- Changed Westfjords to Westfjords Region (Vestfirðir). Duplicate of ID 3430.
    ('3433', 'Eastern Region', '100'), -- Austurland
    ('3434', 'Southern Region', '100'), -- Suðurland
    ('3435', 'Northwestern Region', '100'), -- Norðurland vestra
    ('3436', 'Western Region', '100'), -- Vesturland
    ('3437', 'Northeastern Region', '100'), -- Norðurland eystra
    ('3438', 'Río Muni', '67'), -- Continental Region
    ('3439', 'Kié-Ntem Province', '67'), -- Kié-Ntem has 'é'
    ('3440', 'Wele-Nzas Province', '67'),
    ('3441', 'Litoral Province', '67'),
    ('3442', 'Insular Region', '67'), -- Región Insular
    ('3443', 'Bioko Sur Province', '67'),
    ('3444', 'Annobón Province', '67'), -- Annobón has 'ó'
    ('3445', 'Centro Sur Province', '67'),
    ('3446', 'Bioko Norte Province', '67'),
    ('3447', 'Chihuahua', '142'), -- State
    ('3448', 'Oaxaca', '142'), -- State
    ('3449', 'Sinaloa', '142'), -- State
    ('3450', 'State of Mexico', '142'), -- Changed México to State of Mexico (Estado de México)
    ('3451', 'Chiapas', '142'), -- State
    ('3452', 'Nuevo León', '142'), -- State (León has 'ó')
    ('3453', 'Durango', '142'), -- State
    ('3454', 'Tabasco', '142'), -- State
    ('3455', 'Querétaro', '142'), -- State (Querétaro has 'é')
    ('3456', 'Aguascalientes', '142'), -- State
    ('3457', 'Baja California', '142'), -- State
    ('3458', 'Tlaxcala', '142'), -- State
    ('3459', 'Guerrero', '142'), -- State
    ('3460', 'Baja California Sur', '142'), -- State
    ('3461', 'San Luis Potosí', '142'), -- State (Potosí has 'í')
    ('3462', 'Zacatecas', '142'), -- State
    ('3463', 'Tamaulipas', '142'), -- State
    ('3464', 'Veracruz', '142'), -- State (Veracruz de Ignacio de la Llave)
    ('3465', 'Morelos', '142'), -- State
    ('3466', 'Yucatán', '142'), -- State (Yucatán has 'á')
    ('3467', 'Quintana Roo', '142'), -- State
    ('3468', 'Sonora', '142'), -- State
    ('3469', 'Guanajuato', '142'), -- State
    ('3470', 'Hidalgo', '142'), -- State
    ('3471', 'Coahuila', '142'), -- State (Coahuila de Zaragoza)
    ('3472', 'Colima', '142'), -- State
    ('3473', 'Mexico City', '142'), -- Capital City / Federal Entity (CDMX)
    ('3474', 'Michoacán', '142'), -- State (Michoacán de Ocampo), Michoacán has 'á'
    ('3475', 'Campeche', '142'), -- State
    ('3476', 'Puebla', '142'), -- State
    ('3477', 'Nayarit', '142'), -- State
    ('3478', 'Krabi', '219'), -- Province
    ('3479', 'Ranong', '219'), -- Province
    ('3480', 'Nong Bua Lam Phu', '219'), -- Province
    ('3481', 'Samut Prakan', '219'), -- Province
    ('3482', 'Surat Thani', '219'), -- Province
    ('3483', 'Lamphun', '219'), -- Province
    ('3484', 'Nong Khai', '219'), -- Province
    ('3485', 'Khon Kaen', '219'), -- Province
    ('3486', 'Chanthaburi', '219'), -- Province
    ('3487', 'Saraburi', '219'), -- Province
    ('3488', 'Phatthalung', '219'), -- Province
    ('3489', 'Uttaradit', '219'), -- Province
    ('3490', 'Sing Buri', '219'), -- Province
    ('3491', 'Chiang Mai', '219'), -- Province
    ('3492', 'Nakhon Sawan', '219'), -- Province
    ('3493', 'Yala', '219'), -- Province
    ('3494', 'Phra Nakhon Si Ayutthaya', '219'), -- Province
    ('3495', 'Nonthaburi', '219'), -- Province
    ('3496', 'Trat', '219'), -- Province
    ('3497', 'Nakhon Ratchasima', '219'), -- Province
    ('3498', 'Chiang Rai', '219'), -- Province
    ('3499', 'Ratchaburi', '219'), -- Province
    ('3500', 'Pathum Thani', '219'), -- Province
    ('3501', 'Sakon Nakhon', '219'), -- Province
    ('3502', 'Samut Songkhram', '219'), -- Province
    ('3503', 'Nakhon Pathom', '219'), -- Province
    ('3504', 'Samut Sakhon', '219'), -- Province
    ('3505', 'Mae Hong Son', '219'), -- Province
    ('3506', 'Phitsanulok', '219'), -- Province
    ('3507', 'Pattaya', '219'), -- Special administrative city within Chon Buri. May be redundant.
    ('3508', 'Prachuap Khiri Khan', '219'), -- Province
    ('3509', 'Loei', '219'), -- Province
    ('3510', 'Roi Et', '219'), -- Province
    ('3511', 'Kanchanaburi', '219'), -- Province
    ('3512', 'Ubon Ratchathani', '219'), -- Province
    ('3513', 'Chon Buri', '219'), -- Province
    ('3514', 'Phichit', '219'), -- Province
    ('3515', 'Phetchabun', '219'), -- Province
    ('3516', 'Kamphaeng Phet', '219'), -- Province
    ('3517', 'Maha Sarakham', '219'), -- Province
    ('3518', 'Rayong', '219'), -- Province
    ('3519', 'Ang Thong', '219'), -- Province
    ('3520', 'Nakhon Si Thammarat', '219'), -- Province
    ('3521', 'Yasothon', '219'), -- Province
    ('3522', 'Chai Nat', '219'), -- Province
    ('3523', 'Amnat Charoen', '219'), -- Province
    ('3524', 'Suphan Buri', '219'), -- Changed Suphanburi to Suphan Buri (Province)
    ('3525', 'Tak', '219'), -- Province
    ('3526', 'Chumphon', '219'), -- Province
    ('3527', 'Udon Thani', '219'), -- Province
    ('3528', 'Phrae', '219'), -- Province
    ('3529', 'Sa Kaeo', '219'), -- Province
    ('3530', 'Nan', '219'), -- Province
    ('3531', 'Surin', '219'), -- Province
    ('3532', 'Phetchaburi', '219'), -- Province
    ('3533', 'Bueng Kan', '219'), -- Province
    ('3534', 'Buri Ram', '219'), -- Province
    ('3535', 'Nakhon Nayok', '219'), -- Province
    ('3536', 'Phuket', '219'), -- Province
    ('3537', 'Satun', '219'), -- Province
    ('3538', 'Phayao', '219'), -- Province
    ('3539', 'Songkhla', '219'), -- Province
    ('3540', 'Pattani', '219'), -- Province
    ('3541', 'Trang', '219'), -- Province
    ('3542', 'Prachin Buri', '219'), -- Province
    ('3543', 'Lopburi', '219'), -- Province (Lop Buri)
    ('3544', 'Lampang', '219'), -- Province
    ('3545', 'Sukhothai', '219'), -- Province
    ('3546', 'Mukdahan', '219'), -- Province
    ('3547', 'Si Sa Ket', '219'), -- Province
    ('3548', 'Nakhon Phanom', '219'), -- Province
    ('3549', 'Phang Nga', '219'), -- Province
    ('3550', 'Kalasin', '219'), -- Province
    ('3551', 'Uthai Thani', '219'), -- Province
    ('3552', 'Chachoengsao', '219'), -- Province
    ('3553', 'Narathiwat', '219'), -- Province
    ('3554', 'Bangkok', '219'), -- Special Administrative Area (Capital)
    ('3555', 'Hiiu County', '69'), -- Hiiumaa (Maakond)
    ('3556', 'Viljandi County', '69'), -- Viljandimaa (Maakond)
    ('3557', 'Tartu County', '69'), -- Tartumaa (Maakond)
    ('3558', 'Valga County', '69'), -- Valgamaa (Maakond)
    ('3559', 'Rapla County', '69'), -- Raplamaa (Maakond)
    ('3560', 'Võru County', '69'), -- Võrumaa (Maakond), Võru has 'õ'
    ('3561', 'Saare County', '69'), -- Saaremaa (Maakond)
    ('3562', 'Pärnu County', '69'), -- Pärnumaa (Maakond)
    ('3563', 'Põlva County', '69'), -- Põlvamaa (Maakond), Põlva has 'õ'
    ('3564', 'Lääne-Viru County', '69'), -- Lääne has 'ä' (Maakond)
    ('3565', 'Jõgeva County', '69'), -- Jõgevamaa (Maakond), Jõgeva has 'õ'
    ('3566', 'Järva County', '69'), -- Järvamaa (Maakond)
    ('3567', 'Harju County', '69'), -- Harjumaa (Maakond - Capital region)
    ('3568', 'Lääne County', '69'), -- Läänemaa (Maakond), Lääne has 'ä'
    ('3569', 'Ida-Viru County', '69'), -- (Maakond)
    ('3570', 'Moyen-Chari Region', '43'), -- (Region)
    ('3571', 'Mayo-Kebbi Ouest Region', '43'), -- (Region)
    ('3572', 'Sila Region', '43'), -- (Region)
    ('3573', 'Hadjer-Lamis Region', '43'), -- Changed Hadjer-Lamis to Hadjer-Lamis Region (Region)
    ('3574', 'Borkou Region', '43'), -- Changed Borkou to Borkou Region (Region)
    ('3575', 'Ennedi-Est Region', '43'), -- Changed Ennedi-Est to Ennedi-Est Region (Region)
    ('3576', 'Guéra Region', '43'), -- Guéra has 'é' (Region)
    ('3577', 'Lac Region', '43'), -- (Region)
    ('3578', 'Ennedi Region (historical)', '43'), -- Split into Ennedi-Est and Ennedi-Ouest in 2012. Added (historical).
    ('3579', 'Tandjilé Region', '43'), -- Tandjilé has 'é' (Region)
    ('3580', 'Mayo-Kebbi Est Region', '43'), -- (Region)
    ('3581', 'Wadi Fira Region', '43'), -- (Region)
    ('3582', 'Ouaddaï Region', '43'), -- Ouaddaï has 'ï' (Region)
    ('3583', 'Barh El Gazel Region', '43'), -- Changed Bahr el Gazel to Barh El Gazel Region (Region)
    ('3584', 'Ennedi-Ouest Region', '43'), -- Changed Ennedi-Ouest to Ennedi-Ouest Region (Region)
    ('3585', 'Logone Occidental Region', '43'), -- (Region)
    ('3586', 'N''Djamena', '43'), -- Capital city with special status
    ('3587', 'Tibesti Region', '43'), -- (Region)
    ('3588', 'Kanem Region', '43'), -- (Region)
    ('3589', 'Mandoul Region', '43'), -- (Region)
    ('3590', 'Batha Region', '43'), -- (Region)
    ('3591', 'Logone Oriental Region', '43'), -- (Region)
    ('3592', 'Salamat Region', '43'), -- (Region)
    ('3593', 'Berry Islands', '17'), -- District
    (
        '3594',
        'North Andros and Berry Islands (historical)',
        '17'
    ), -- Changed Nichollstown and Berry Islands to North Andros and Berry Islands (historical). Replaced by North Andros, Central Andros, Berry Islands districts.
    ('3595', 'Hope Town', '17'), -- Changed Green Turtle Cay to Hope Town (District in Abaco, Green Turtle Cay is within it). ID conflict with 3624. Assuming this one is Hope Town.
    ('3596', 'Central Eleuthera', '17'), -- District
    ('3597', 'Governor''s Harbour (historical)', '17'), -- Fixed escaping. Merged into Central Eleuthera. Added (historical).
    ('3598', 'East Grand Bahama', '17'), -- Changed High Rock to East Grand Bahama (District). High Rock is chief settlement. ID conflict with 3614. Assuming this one is East Grand Bahama.
    ('3599', 'West Grand Bahama', '17'), -- District
    ('3600', 'Rum Cay', '17'), -- Changed Rum Cay District to Rum Cay (District).
    ('3601', 'Acklins', '17'), -- District
    ('3602', 'North Eleuthera', '17'), -- District
    ('3603', 'Central Abaco', '17'), -- District
    ('3604', 'Marsh Harbour (historical)', '17'), -- Merged into Central Abaco. Added (historical).
    ('3605', 'Black Point', '17'), -- District (Exuma Cays)
    ('3606', 'South Abaco', '17'), -- Changed Sandy Point to South Abaco (District). Sandy Point is chief settlement. ID conflict with 3608. Assuming this one is South Abaco.
    ('3607', 'South Eleuthera', '17'), -- District
    ('3608', 'South Abaco', '17'), -- District. Duplicate of 3606.
    ('3609', 'Inagua', '17'), -- District
    ('3610', 'Long Island', '17'), -- District
    ('3611', 'Cat Island', '17'), -- District
    ('3612', 'Exuma', '17'), -- District
    ('3613', 'Harbour Island', '17'), -- District
    ('3614', 'East Grand Bahama', '17'), -- District. Duplicate of 3598.
    ('3615', 'Ragged Island', '17'), -- District
    ('3616', 'North Abaco', '17'), -- District
    ('3617', 'North Andros', '17'), -- District
    (
        '3618',
        'South Andros and Mangrove Cay (historical)',
        '17'
    ), -- Changed Kemps Bay to South Andros and Mangrove Cay (historical). Replaced by South Andros, Mangrove Cay districts. Kemps Bay is chief settlement of S. Andros.
    ('3619', 'Central Andros', '17'), -- Changed Fresh Creek to Central Andros (District). Fresh Creek is chief settlement. ID conflict with 3631. Assuming this one is Central Andros.
    (
        '3620',
        'San Salvador and Rum Cay (historical)',
        '17'
    ), -- Replaced by San Salvador, Rum Cay districts. Added (historical).
    ('3621', 'Crooked Island and Long Cay', '17'), -- Changed Crooked Island to Crooked Island and Long Cay (District)
    ('3622', 'South Andros', '17'), -- District
    ('3623', 'South Eleuthera (historical)', '17'), -- Changed Rock Sound to South Eleuthera (historical). Rock Sound is chief settlement. Name already used by ID 3607. Added (historical).
    ('3624', 'Hope Town', '17'), -- District (Abaco). Duplicate of 3595.
    ('3625', 'Mangrove Cay', '17'), -- District
    ('3626', 'Freeport (historical)', '17'), -- City within Grand Bahama, administrative status changed. Added (historical).
    ('3627', 'San Salvador', '17'), -- Changed San Salvador Island to San Salvador (District)
    (
        '3628',
        'Acklins and Crooked Islands (historical)',
        '17'
    ), -- Replaced by Acklins, Crooked Island districts. Added (historical).
    ('3629', 'Bimini', '17'), -- District (Bimini and Cat Cay)
    ('3630', 'Spanish Wells', '17'), -- District (Eleuthera)
    ('3631', 'Central Andros', '17'), -- District. Duplicate of 3619.
    ('3632', 'Grand Cay', '17'), -- District (Abaco)
    ('3633', 'Mayaguana', '17'), -- Changed Mayaguana District to Mayaguana (District)
    ('3634', 'San Juan Province', '11'), -- Argentina
    ('3635', 'Santiago del Estero Province', '11'),
    ('3636', 'San Luis Province', '11'),
    ('3637', 'Tucumán Province', '11'), -- Tucumán has 'á'
    ('3638', 'Corrientes Province', '11'), -- Changed Corrientes to Corrientes Province
    ('3639', 'Río Negro Province', '11'), -- Río has 'í'
    ('3640', 'Chaco Province', '11'),
    ('3641', 'Santa Fe Province', '11'),
    ('3642', 'Córdoba Province', '11'), -- Córdoba has 'ó'
    ('3643', 'Salta Province', '11'),
    ('3644', 'Misiones Province', '11'),
    ('3645', 'Jujuy Province', '11'),
    ('3646', 'Mendoza Province', '11'), -- Changed Mendoza to Mendoza Province
    ('3647', 'Catamarca Province', '11'),
    ('3648', 'Neuquén Province', '11'), -- Neuquén has 'é'
    ('3649', 'Santa Cruz Province', '11'),
    (
        '3650',
        'Tierra del Fuego, Antarctica and South Atlantic Islands Province',
        '11'
    ), -- Changed Tierra del Fuego Province to include full name
    ('3651', 'Chubut Province', '11'),
    ('3652', 'Formosa Province', '11'),
    ('3653', 'La Rioja Province', '11'),
    ('3654', 'Entre Ríos Province', '11'), -- Entre Ríos has 'í'
    ('3655', 'La Pampa Province', '11'), -- Changed La Pampa to La Pampa Province
    ('3656', 'Buenos Aires Province', '11'),
    ('3657', 'Quiché Department', '90'), -- El Quiché
    ('3658', 'Jalapa Department', '90'),
    ('3659', 'Izabal Department', '90'),
    ('3660', 'Suchitepéquez Department', '90'), -- Suchitepéquez has 'é'
    ('3661', 'Sololá Department', '90'), -- Sololá has 'á'
    ('3662', 'El Progreso Department', '90'),
    ('3663', 'Totonicapán Department', '90'), -- Totonicapán has 'á'
    ('3664', 'Retalhuleu Department', '90'),
    ('3665', 'Santa Rosa Department', '90'),
    ('3666', 'Chiquimula Department', '90'),
    ('3667', 'San Marcos Department', '90'),
    ('3668', 'Quetzaltenango Department', '90'),
    ('3669', 'Petén Department', '90'), -- Petén has 'é'
    ('3670', 'Huehuetenango Department', '90'),
    ('3671', 'Alta Verapaz Department', '90'),
    ('3672', 'Guatemala Department', '90'),
    ('3673', 'Jutiapa Department', '90'),
    ('3674', 'Baja Verapaz Department', '90'),
    ('3675', 'Chimaltenango Department', '90'),
    ('3676', 'Sacatepéquez Department', '90'), -- Sacatepéquez has 'é'
    ('3677', 'Escuintla Department', '90'),
    ('3678', 'Madre de Dios Department', '173'), -- Changed Madre de Dios to Madre de Dios Department
    ('3679', 'Huancavelica Department', '173'), -- Changed Huancavelica to Huancavelica Department
    ('3680', 'Áncash Department', '173'), -- Changed Áncash to Áncash Department, Áncash has 'Á'
    ('3681', 'Arequipa Department', '173'), -- Changed Arequipa to Arequipa Department
    ('3682', 'Puno Department', '173'), -- Changed Puno to Puno Department
    ('3683', 'La Libertad Department', '173'),
    ('3684', 'Ucayali Department', '173'), -- Changed Ucayali to Ucayali Department
    ('3685', 'Amazonas Department', '173'), -- Changed Amazonas to Amazonas Department
    ('3686', 'Pasco Department', '173'), -- Changed Pasco to Pasco Department
    ('3687', 'Huánuco Department', '173'), -- Changed Huanuco to Huánuco Department, Huánuco has 'á'
    ('3688', 'Cajamarca Department', '173'), -- Changed Cajamarca to Cajamarca Department
    ('3689', 'Tumbes Department', '173'), -- Changed Tumbes to Tumbes Department
    -- Missing ID 3690
    ('3691', 'Cusco Department', '173'), -- Changed Cusco to Cusco Department
    ('3692', 'Ayacucho Department', '173'), -- Changed Ayacucho to Ayacucho Department
    ('3693', 'Junín Department', '173'), -- Changed Junín to Junín Department, Junín has 'í'
    ('3694', 'San Martín Department', '173'), -- Changed San Martín to San Martín Department, Martín has 'í'
    ('3695', 'Lima Province', '173'), -- Changed Lima to Lima Province (Special status province, not part of Lima Region)
    ('3696', 'Tacna Department', '173'), -- Changed Tacna to Tacna Department
    ('3697', 'Piura Department', '173'), -- Changed Piura to Piura Department
    ('3698', 'Moquegua Department', '173'), -- Changed Moquegua to Moquegua Department
    ('3699', 'Apurímac Department', '173'), -- Changed Apurímac to Apurímac Department, Apurímac has 'í'
    ('3700', 'Ica Department', '173'), -- Changed Ica to Ica Department
    ('3701', 'Callao Constitutional Province', '173'), -- Changed Callao to Callao Constitutional Province (Region-level status)
    ('3702', 'Lambayeque Department', '173'), -- Changed Lambayeque to Lambayeque Department
    ('3703', 'Redonda', '10'), -- Dependency of Antigua and Barbuda (uninhabited)
    ('3704', 'Saint Peter Parish', '10'), -- Antigua and Barbuda
    ('3705', 'Saint Paul Parish', '10'),
    ('3706', 'Saint John Parish', '10'), -- (includes capital St. John's)
    ('3707', 'Saint Mary Parish', '10'),
    ('3708', 'Barbuda', '10'), -- Dependency
    ('3709', 'Saint George Parish', '10'),
    ('3710', 'Saint Philip Parish', '10'),
    ('3711', 'South Bačka District', '196'), -- Južnobački okrug, Bačka has 'č'
    ('3712', 'Pirot District', '196'), -- Pirotski okrug
    ('3713', 'South Banat District', '196'), -- Južnobanatski okrug
    ('3714', 'North Bačka District', '196'), -- Severnobački okrug, Bačka has 'č'
    ('3715', 'Jablanica District', '196'), -- Jablanički okrug, Jablanica has 'č'
    ('3716', 'Central Banat District', '196'), -- Srednjobanatski okrug
    ('3717', 'Bor District', '196'), -- Borski okrug
    ('3718', 'Toplica District', '196'), -- Toplički okrug, Toplica has 'č'
    ('3719', 'Mačva District', '196'), -- Mačvanski okrug, Mačva has 'č'
    ('3720', 'Rasina District', '196'), -- Rasinski okrug
    ('3721', 'Pčinja District', '196'), -- Pčinjski okrug, Pčinja has 'č'
    ('3722', 'Nišava District', '196'), -- Nišavski okrug, Nišava has 'š'
    ('3723', 'Prizren District (Kosovo)', '248'), -- Changed country ID from Serbia (196) to Kosovo (248). Kosovo declared independence 2008. Okrug exist under Serbian law, but Kosovo uses its own districts. Added (Kosovo).
    ('3724', 'Kolubara District', '196'), -- Kolubarski okrug
    ('3725', 'Raška District', '196'), -- Raški okrug, Raška has 'š'
    ('3726', 'West Bačka District', '196'), -- Zapadnobački okrug, Bačka has 'č'
    ('3727', 'Moravica District', '196'), -- Moravički okrug, Moravica has 'č'
    ('3728', 'Belgrade City', '196'), -- Changed Belgrade to Belgrade City (Special district status)
    ('3729', 'Zlatibor District', '196'), -- Zlatiborski okrug
    -- Missing ID 3730
    ('3731', 'Zaječar District', '196'), -- Zaječarski okrug, Zaječar has 'č'
    ('3732', 'Braničevo District', '196'), -- Braničevski okrug, Braničevo has 'č'
    ('3733', 'Vojvodina', '196'), -- Autonomous Province of Vojvodina
    ('3734', 'Šumadija District', '196'), -- Šumadijski okrug, Šumadija has 'Š'
    -- Missing ID 3735
    ('3736', 'North Banat District', '196'), -- Severnobanatski okrug
    ('3737', 'Pomoravlje District', '196'), -- Pomoravski okrug
    ('3738', 'Peć District (Kosovo)', '248'), -- Changed country ID from Serbia (196) to Kosovo (248). Added (Kosovo). Peć has 'ć'. Kosovo name: Peja.
    -- Missing ID 3739
    ('3740', 'Srem District', '196'), -- Sremski okrug
    ('3741', 'Podunavlje District', '196'), -- Podunavski okrug
    ('3742', 'Westmoreland Parish', '108'), -- Jamaica
    ('3743', 'Saint Elizabeth Parish', '108'),
    ('3744', 'Saint Ann Parish', '108'),
    ('3745', 'Saint James Parish', '108'),
    ('3746', 'Saint Catherine Parish', '108'),
    ('3747', 'Saint Mary Parish', '108'),
    ('3748', 'Kingston Parish', '108'), -- (Often grouped with St Andrew as Kingston and St Andrew Corporation - KSAC)
    ('3749', 'Hanover Parish', '108'),
    ('3750', 'Saint Thomas Parish', '108'),
    ('3751', 'Saint Andrew Parish', '108'), -- Changed Saint Andrew to Saint Andrew Parish (Often grouped with Kingston as KSAC)
    ('3752', 'Portland Parish', '108'),
    ('3753', 'Clarendon Parish', '108'),
    ('3754', 'Manchester Parish', '108'),
    ('3755', 'Trelawny Parish', '108'),
    ('3756', 'Dennery Quarter', '186'), -- Saint Lucia
    ('3757', 'Anse la Raye Quarter', '186'),
    ('3758', 'Castries Quarter', '186'), -- (Capital)
    ('3759', 'Laborie Quarter', '186'),
    ('3760', 'Choiseul Quarter', '186'),
    ('3761', 'Canaries Quarter', '186'), -- Changed Canaries to Canaries Quarter
    ('3762', 'Micoud Quarter', '186'),
    ('3763', 'Vieux Fort Quarter', '186'),
    ('3764', 'Soufrière Quarter', '186'), -- Soufrière has 'è'
    ('3765', 'Praslin Quarter', '186'),
    ('3766', 'Gros Islet Quarter', '186'),
    ('3767', 'Dauphin Quarter (historical)', '186'), -- Merged into Gros Islet. Added (historical).
    ('3768', 'Hưng Yên Province', '240'), -- Changed Hưng Yên to Hưng Yên Province, Hưng Yên has 'ư', 'ê'
    ('3769', 'Đồng Tháp Province', '240'), -- Changed Đồng Tháp to Đồng Tháp Province, Đồng Tháp has 'Đ', 'ồ', 'á'
    ('3770', 'Bà Rịa-Vũng Tàu Province', '240'), -- Bà Rịa has 'à', 'ị', Vũng Tàu has 'ũ', 'à'
    ('3771', 'Thanh Hóa Province', '240'), -- Changed Thanh Hóa to Thanh Hóa Province, Thanh Hóa has 'ó'
    ('3772', 'Kon Tum Province', '240'), -- Changed Kon Tum to Kon Tum Province
    ('3773', 'Điện Biên Province', '240'), -- Điện Biên has 'Đ', 'ệ', 'ê'
    ('3774', 'Vĩnh Phúc Province', '240'), -- Vĩnh Phúc has 'ĩ', 'ú'
    ('3775', 'Thái Bình Province', '240'), -- Thái Bình has 'á', 'ì'
    ('3776', 'Quảng Nam Province', '240'), -- Quảng Nam has 'ả'
    ('3777', 'Hậu Giang Province', '240'), -- Hậu Giang has 'ậ'
    ('3778', 'Cà Mau Province', '240'), -- Cà Mau has 'à'
    ('3779', 'Hà Giang Province', '240'), -- Hà Giang has 'à'
    ('3780', 'Nghệ An Province', '240'), -- Nghệ An has 'ệ'
    ('3781', 'Tiền Giang Province', '240'), -- Tiền Giang has 'ề'
    ('3782', 'Cao Bằng Province', '240'), -- Cao Bằng has 'ằ'
    ('3783', 'Hải Phòng Municipality', '240'), -- Changed Haiphong to Hải Phòng Municipality, Hải Phòng has 'ả', 'ò'
    ('3784', 'Yên Bái Province', '240'), -- Yên Bái has 'ê', 'á'
    ('3785', 'Bình Dương Province', '240'), -- Bình Dương has 'ì', 'ươ'
    ('3786', 'Ninh Bình Province', '240'), -- Ninh Bình has 'ì'
    ('3787', 'Bình Thuận Province', '240'), -- Bình Thuận has 'ì', 'ậ'
    ('3788', 'Ninh Thuận Province', '240'), -- Ninh Thuận has 'ậ'
    ('3789', 'Nam Định Province', '240'), -- Nam Định has 'Đ', 'ị'
    ('3790', 'Vĩnh Long Province', '240'), -- Vĩnh Long has 'ĩ'
    ('3791', 'Bắc Ninh Province', '240'), -- Bắc Ninh has 'ắ'
    ('3792', 'Lạng Sơn Province', '240'), -- Lạng Sơn has 'ạ', 'ơ'
    ('3793', 'Khánh Hòa Province', '240'), -- Khánh Hòa has 'á', 'ò'
    ('3794', 'An Giang Province', '240'),
    ('3795', 'Tuyên Quang Province', '240'), -- Tuyên Quang has 'ê'
    ('3796', 'Bến Tre Province', '240'), -- Bến Tre has 'ế'
    ('3797', 'Bình Phước Province', '240'), -- Bình Phước has 'ì', 'ướ'
    ('3798', 'Thừa Thiên Huế Province', '240'), -- Changed Thừa Thiên-Huế to Thừa Thiên Huế Province, Thừa Thiên has 'ừ', 'ê', Huế has 'ế'
    ('3799', 'Hòa Bình Province', '240'), -- Hòa Bình has 'ò', 'ì'
    ('3800', 'Kiên Giang Province', '240'), -- Kiên Giang has 'ê'
    ('3801', 'Phú Thọ Province', '240'), -- Phú Thọ has 'ú', 'ọ'
    ('3802', 'Hà Nam Province', '240'), -- Hà Nam has 'à'
    ('3803', 'Quảng Trị Province', '240'), -- Quảng Trị has 'ả', 'ị'
    ('3804', 'Bạc Liêu Province', '240'), -- Bạc Liêu has 'ạ', 'ê'
    ('3805', 'Trà Vinh Province', '240'), -- Trà Vinh has 'à'
    ('3806', 'Đà Nẵng Municipality', '240'), -- Changed Da Nang to Đà Nẵng Municipality, Đà Nẵng has 'Đ', 'à', 'ẵ'
    ('3807', 'Thái Nguyên Province', '240'), -- Thái Nguyên has 'á', 'ê'
    ('3808', 'Long An Province', '240'),
    ('3809', 'Quảng Bình Province', '240'), -- Quảng Bình has 'ả', 'ì'
    ('3810', 'Hà Nội Municipality', '240'), -- Changed Hanoi to Hà Nội Municipality (Capital), Hà Nội has 'à', 'ộ'
    ('3811', 'Hồ Chí Minh City Municipality', '240'), -- Hồ Chí Minh has 'ồ', 'í'
    ('3812', 'Sơn La Province', '240'), -- Sơn La has 'ơ'
    ('3813', 'Gia Lai Province', '240'),
    ('3814', 'Quảng Ninh Province', '240'), -- Quảng Ninh has 'ả'
    ('3815', 'Bắc Giang Province', '240'), -- Bắc Giang has 'ắ'
    ('3816', 'Hà Tĩnh Province', '240'), -- Hà Tĩnh has 'à', 'ĩ'
    ('3817', 'Lào Cai Province', '240'), -- Lào Cai has 'à'
    ('3818', 'Lâm Đồng Province', '240'), -- Lâm Đồng has 'â', 'ồ'
    ('3819', 'Sóc Trăng Province', '240'), -- Sóc Trăng has 'ó'
    ('3820', 'Hà Tây Province (historical)', '240'), -- Merged into Hanoi 2008. Added (historical). Hà Tây has 'à'.
    ('3821', 'Đồng Nai Province', '240'), -- Đồng Nai has 'Đ', 'ồ'
    ('3822', 'Bắc Kạn Province', '240'), -- Bắc Kạn has 'ắ', 'ạ'
    ('3823', 'Đắk Nông Province', '240'), -- Đắk Nông has 'Đ', 'ắ'
    ('3824', 'Phú Yên Province', '240'), -- Phú Yên has 'ú', 'ê'
    ('3825', 'Lai Châu Province', '240'), -- Lai Châu has 'â'
    ('3826', 'Tây Ninh Province', '240'), -- Tây Ninh has 'â'
    ('3827', 'Hải Dương Province', '240'), -- Hải Dương has 'ả', 'ươ'
    ('3828', 'Quảng Ngãi Province', '240'), -- Quảng Ngãi has 'ả', 'ã'
    ('3829', 'Đắk Lắk Province', '240'), -- Đắk Lắk has 'Đ', 'ắ'
    ('3830', 'Bình Định Province', '240'), -- Bình Định has 'ì', 'ị'
    ('3831', 'Saint Peter Basseterre Parish', '185'), -- Saint Kitts and Nevis
    ('3832', 'Nevis', '185'), -- Island (has own Assembly within the federation)
    (
        '3833',
        'Christ Church Nichola Town Parish',
        '185'
    ),
    ('3834', 'Saint Paul Capisterre Parish', '185'),
    ('3835', 'Saint James Windward Parish', '185'), -- (Nevis)
    ('3836', 'Saint Anne Sandy Point Parish', '185'),
    ('3837', 'Saint George Gingerland Parish', '185'), -- (Nevis)
    ('3838', 'Saint Paul Charlestown Parish', '185'), -- (Nevis)
    ('3839', 'Saint Thomas Lowland Parish', '185'), -- (Nevis)
    ('3840', 'Saint John Figtree Parish', '185'), -- (Nevis)
    ('3841', 'Saint Kitts', '185'), -- Island (location of most parishes)
    (
        '3842',
        'Saint Thomas Middle Island Parish',
        '185'
    ),
    ('3843', 'Trinity Palmetto Point Parish', '185'),
    ('3844', 'Saint Mary Cayon Parish', '185'),
    ('3845', 'Saint John Capisterre Parish', '185'),
    ('3846', 'Daegu Metropolitan City', '116'), -- Changed Daegu to Daegu Metropolitan City
    ('3847', 'Gyeonggi Province', '116'), -- Gyeonggi-do
    ('3848', 'Incheon Metropolitan City', '116'), -- Changed Incheon to Incheon Metropolitan City
    ('3849', 'Seoul Special City', '116'), -- Changed Seoul to Seoul Special City (Capital)
    ('3850', 'Daejeon Metropolitan City', '116'), -- Changed Daejeon to Daejeon Metropolitan City
    ('3851', 'North Jeolla Province', '116'), -- Jeollabuk-do
    ('3852', 'Ulsan Metropolitan City', '116'), -- Changed Ulsan to Ulsan Metropolitan City
    (
        '3853',
        'Jeju Special Self-Governing Province',
        '116'
    ), -- Changed Jeju to Jeju Special Self-Governing Province (Teukbyeol-jachido)
    ('3854', 'North Chungcheong Province', '116'), -- Chungcheongbuk-do
    ('3855', 'North Gyeongsang Province', '116'), -- Gyeongsangbuk-do
    ('3856', 'South Jeolla Province', '116'), -- Jeollanam-do
    ('3857', 'South Gyeongsang Province', '116'), -- Gyeongsangnam-do
    ('3858', 'Gwangju Metropolitan City', '116'), -- Changed Gwangju to Gwangju Metropolitan City
    ('3859', 'South Chungcheong Province', '116'), -- Chungcheongnam-do
    ('3860', 'Busan Metropolitan City', '116'), -- Changed Busan to Busan Metropolitan City
    (
        '3861',
        'Sejong Special Self-Governing City',
        '116'
    ), -- Changed Sejong City to Sejong Special Self-Governing City (Teukbyeol-jachisi)
    (
        '3862',
        'Gangwon Special Self-Governing Province',
        '116'
    ), -- Changed Gangwon Province to Gangwon Special Self-Governing Province (Teukbyeol-jachido - status change 2023)
    ('3863', 'Saint Patrick Parish', '87'), -- Grenada
    ('3864', 'Saint George Parish', '87'), -- (Capital parish)
    ('3865', 'Saint Andrew Parish', '87'),
    ('3866', 'Saint Mark Parish', '87'),
    ('3867', 'Carriacou and Petite Martinique', '87'), -- Dependency
    ('3868', 'Saint John Parish', '87'),
    ('3869', 'Saint David Parish', '87'),
    ('3870', 'Ghazni Province', '1'), -- Changed Ghazni to Ghazni Province (Afghanistan - Wilayat)
    ('3871', 'Badghis Province', '1'), -- Changed Badghis to Badghis Province (Wilayat)
    ('3872', 'Bamyan Province', '1'), -- Changed Bamyan to Bamyan Province (Wilayat)
    ('3873', 'Helmand Province', '1'), -- Changed Helmand to Helmand Province (Wilayat)
    ('3874', 'Zabul Province', '1'), -- Changed Zabul to Zabul Province (Wilayat)
    ('3875', 'Baghlan Province', '1'), -- Changed Baghlan to Baghlan Province (Wilayat)
    ('3876', 'Kunar Province', '1'), -- Changed Kunar to Kunar Province (Wilayat)
    ('3877', 'Paktika Province', '1'), -- Changed Paktika to Paktika Province (Wilayat)
    ('3878', 'Khost Province', '1'), -- Changed Khost to Khost Province (Wilayat)
    ('3879', 'Kapisa Province', '1'), -- Changed Kapisa to Kapisa Province (Wilayat)
    ('3880', 'Nuristan Province', '1'), -- Changed Nuristan to Nuristan Province (Wilayat)
    ('3881', 'Panjshir Province', '1'), -- Changed Panjshir to Panjshir Province (Wilayat)
    ('3882', 'Nangarhar Province', '1'), -- Changed Nangarhar to Nangarhar Province (Wilayat)
    ('3883', 'Samangan Province', '1'), -- Changed Samangan to Samangan Province (Wilayat)
    ('3884', 'Balkh Province', '1'), -- Changed Balkh to Balkh Province (Wilayat)
    ('3885', 'Sar-e Pol Province', '1'), -- Changed Sar-e Pol to Sar-e Pol Province (Wilayat)
    ('3886', 'Jowzjan Province', '1'), -- Changed Jowzjan to Jowzjan Province (Wilayat)
    ('3887', 'Herat Province', '1'), -- Changed Herat to Herat Province (Wilayat)
    ('3888', 'Ghōr Province', '1'), -- Fixed char (Wilayat)
    ('3889', 'Faryab Province', '1'), -- Changed Faryab to Faryab Province (Wilayat)
    ('3890', 'Kandahar Province', '1'), -- Changed Kandahar to Kandahar Province (Wilayat)
    ('3891', 'Laghman Province', '1'), -- Changed Laghman to Laghman Province (Wilayat)
    ('3892', 'Daykundi Province', '1'), -- Changed Daykundi to Daykundi Province (Wilayat)
    ('3893', 'Takhar Province', '1'), -- Changed Takhar to Takhar Province (Wilayat)
    ('3894', 'Paktia Province', '1'), -- Changed Paktia to Paktia Province (Wilayat)
    ('3895', 'Parwan Province', '1'), -- Changed Parwan to Parwan Province (Wilayat)
    ('3896', 'Nimruz Province', '1'), -- Changed Nimruz to Nimruz Province (Wilayat)
    ('3897', 'Logar Province', '1'), -- Changed Logar to Logar Province (Wilayat)
    ('3898', 'Urozgan Province', '1'), -- Changed Urozgan to Urozgan Province (Wilayat)
    ('3899', 'Farah Province', '1'), -- Changed Farah to Farah Province (Wilayat)
    ('3900', 'Kunduz Province', '1'), -- (Wilayat)
    ('3901', 'Badakhshan Province', '1'), -- Changed Badakhshan to Badakhshan Province (Wilayat)
    ('3902', 'Kabul Province', '1'), -- Changed Kabul to Kabul Province (Wilayat - Capital)
    ('3903', 'Victoria', '14'), -- State (Australia)
    ('3904', 'South Australia', '14'), -- State
    ('3905', 'Queensland', '14'), -- State
    ('3906', 'Western Australia', '14'), -- State
    ('3907', 'Australian Capital Territory', '14'), -- Territory
    ('3908', 'Tasmania', '14'), -- State
    ('3909', 'New South Wales', '14'), -- State
    ('3910', 'Northern Territory', '14'), -- Territory
    ('3911', 'Vavaʻu', '222'), -- Fixed char (Division - Tonga)
    ('3912', 'Tongatapu', '222'), -- Division (Capital)
    ('3913', 'Haʻapai', '222'), -- Fixed char (Division)
    ('3914', 'Niuas', '222'), -- Division
    ('3915', 'ʻEua', '222'), -- Fixed char (Division)
    ('3916', 'Markazi Province', '103'), -- Iran (Ostan)
    ('3917', 'Khuzestan Province', '103'), -- Ostan
    ('3918', 'Ilam Province', '103'), -- Ostan
    ('3919', 'Kermanshah Province', '103'), -- Ostan
    ('3920', 'Gilan Province', '103'), -- Ostan
    (
        '3921',
        'Chaharmahal and Bakhtiari Province',
        '103'
    ), -- Ostan
    ('3922', 'Qom Province', '103'), -- Ostan
    ('3923', 'Isfahan Province', '103'), -- Ostan
    ('3924', 'West Azerbaijan Province', '103'), -- Ostan
    ('3925', 'Zanjan Province', '103'), -- Ostan
    (
        '3926',
        'Kohgiluyeh and Boyer-Ahmad Province',
        '103'
    ), -- Ostan
    ('3927', 'Razavi Khorasan Province', '103'), -- Ostan
    ('3928', 'Lorestan Province', '103'), -- Ostan
    ('3929', 'Alborz Province', '103'), -- Ostan
    ('3930', 'South Khorasan Province', '103'), -- Ostan
    ('3931', 'Sistan and Baluchestan Province', '103'), -- Changed Sistan and Baluchestan to Sistan and Baluchestan Province (Ostan)
    ('3932', 'Bushehr Province', '103'), -- Ostan
    ('3933', 'Golestan Province', '103'), -- Ostan
    ('3934', 'Ardabil Province', '103'), -- Ostan
    ('3935', 'Kurdistan Province', '103'), -- Ostan
    ('3936', 'Yazd Province', '103'), -- Ostan
    ('3937', 'Hormozgan Province', '103'), -- Ostan
    ('3938', 'Mazandaran Province', '103'), -- Ostan
    ('3939', 'Fars Province', '103'), -- Ostan
    ('3940', 'Semnan Province', '103'), -- Ostan
    ('3941', 'Qazvin Province', '103'), -- Ostan
    ('3942', 'North Khorasan Province', '103'), -- Ostan
    ('3943', 'Kerman Province', '103'), -- Ostan
    ('3944', 'East Azerbaijan Province', '103'), -- Ostan
    ('3945', 'Tehran Province', '103'), -- Ostan (Capital)
    ('3946', 'Niutao', '228'), -- Changed Niutao Island Council to Niutao (Island Council - Tuvalu)
    ('3947', 'Nanumanga', '228'), -- Island Council
    ('3948', 'Nui', '228'), -- Island Council
    ('3949', 'Nanumea', '228'), -- Island Council
    ('3950', 'Vaitupu', '228'), -- Island Council
    ('3951', 'Funafuti', '228'), -- Island Council (Capital Atoll)
    ('3952', 'Nukufetau', '228'), -- Island Council
    ('3953', 'Nukulaelae', '228'), -- Island Council
    ('3954', 'Dhi Qar Governorate', '104'), -- Iraq (Muhafazah)
    ('3955', 'Babylon Governorate', '104'), -- Babil (Muhafazah)
    ('3956', 'Al-Qādisiyyah Governorate', '104'), -- Fixed char (Muhafazah)
    ('3957', 'Karbala Governorate', '104'), -- Muhafazah
    ('3958', 'Al Muthanna Governorate', '104'), -- Muhafazah
    ('3959', 'Baghdad Governorate', '104'), -- Muhafazah (Capital)
    ('3960', 'Basra Governorate', '104'), -- Muhafazah
    ('3961', 'Saladin Governorate', '104'), -- Salah ad Din (Muhafazah)
    ('3962', 'Najaf Governorate', '104'), -- Muhafazah
    ('3963', 'Nineveh Governorate', '104'), -- Muhafazah
    ('3964', 'Al Anbar Governorate', '104'), -- Muhafazah
    ('3965', 'Diyala Governorate', '104'), -- Muhafazah
    ('3966', 'Maysan Governorate', '104'), -- Muhafazah
    ('3967', 'Dohuk Governorate', '104'), -- Muhafazah (Kurdistan Region)
    ('3968', 'Erbil Governorate', '104'), -- Muhafazah (Kurdistan Region Capital)
    ('3969', 'Sulaymaniyah Governorate', '104'), -- Muhafazah (Kurdistan Region)
    ('3970', 'Wasit Governorate', '104'), -- Muhafazah
    ('3971', 'Kirkuk Governorate', '104'), -- Muhafazah (Disputed)
    ('3972', 'Svay Rieng Province', '37'), -- Cambodia (Khaet)
    ('3973', 'Preah Vihear Province', '37'), -- Khaet
    ('3974', 'Prey Veng Province', '37'), -- Khaet
    ('3975', 'Takéo Province', '37'), -- Fixed char (Khaet)
    ('3976', 'Battambang Province', '37'), -- Khaet
    ('3977', 'Pursat Province', '37'), -- Khaet
    ('3978', 'Kep Province', '37'), -- Khaet (Province-level municipality)
    ('3979', 'Kampong Chhnang Province', '37'), -- Khaet
    ('3980', 'Pailin Province', '37'), -- Khaet (Province-level municipality)
    ('3981', 'Kampot Province', '37'), -- Khaet
    ('3982', 'Koh Kong Province', '37'), -- Khaet
    ('3983', 'Kandal Province', '37'), -- Khaet
    ('3984', 'Banteay Meanchey Province', '37'), -- Khaet
    ('3985', 'Mondulkiri Province', '37'), -- Khaet
    ('3986', 'Kratié Province', '37'), -- Fixed char (Khaet)
    ('3987', 'Oddar Meanchey Province', '37'), -- Khaet
    ('3988', 'Kampong Speu Province', '37'), -- Khaet
    ('3989', 'Preah Sihanouk Province', '37'), -- Changed Sihanoukville Province to Preah Sihanouk Province (Khaet - Province-level municipality)
    ('3990', 'Ratanakiri Province', '37'), -- Khaet
    ('3991', 'Kampong Cham Province', '37'), -- Khaet
    ('3992', 'Siem Reap Province', '37'), -- Khaet
    ('3993', 'Stung Treng Province', '37'), -- Khaet
    ('3994', 'Phnom Penh', '37'), -- Autonomous Municipality (Capital)
    ('3995', 'North Hamgyong Province', '115'), -- North Korea (Do)
    ('3996', 'Ryanggang Province', '115'), -- Do (Yanggang)
    ('3997', 'South Pyongan Province', '115'), -- Do (P'yŏngan-namdo)
    ('3998', 'Chagang Province', '115'), -- Do (Chagang-do)
    ('3999', 'Kangwon Province', '115'), -- Do (Kangwŏn-do)
    ('4000', 'South Hamgyong Province', '115'), -- Do (Hamgyŏng-namdo)
    ('4001', 'Rason Special City', '115'), -- Changed Rason to Rason Special City (Rajin-Sŏnbong Teukbyeolsi)
    ('4002', 'North Pyongan Province', '115'), -- Do (P'yŏngan-bukto)
    ('4003', 'South Hwanghae Province', '115'), -- Do (Hwanghae-namdo)
    ('4004', 'North Hwanghae Province', '115'), -- Do (Hwanghae-bukto)
    ('4005', 'Pyongyang Directly Governed City', '115'), -- Changed Pyongyang to Pyongyang Directly Governed City (P'yŏngyang Chikhalsi - Capital)
    ('4006', 'Meghalaya', '101'), -- State (India)
    ('4007', 'Haryana', '101'), -- State
    ('4008', 'Maharashtra', '101'), -- State
    ('4009', 'Goa', '101'), -- State
    ('4010', 'Manipur', '101'), -- State
    ('4011', 'Puducherry', '101'), -- Union Territory
    ('4012', 'Telangana', '101'), -- State
    ('4013', 'Odisha', '101'), -- State (Formerly Orissa)
    ('4014', 'Rajasthan', '101'), -- State
    ('4015', 'Punjab', '101'), -- State
    ('4016', 'Uttarakhand', '101'), -- State
    ('4017', 'Andhra Pradesh', '101'), -- State
    ('4018', 'Nagaland', '101'), -- State
    ('4019', 'Lakshadweep', '101'), -- Union Territory
    ('4020', 'Himachal Pradesh', '101'), -- State
    (
        '4021',
        'National Capital Territory of Delhi',
        '101'
    ), -- Changed Delhi to National Capital Territory of Delhi (Union Territory)
    ('4022', 'Uttar Pradesh', '101'), -- State
    ('4023', 'Andaman and Nicobar Islands', '101'), -- Union Territory
    ('4024', 'Arunachal Pradesh', '101'), -- State
    ('4025', 'Jharkhand', '101'), -- State
    ('4026', 'Karnataka', '101'), -- State
    ('4027', 'Assam', '101'), -- State
    ('4028', 'Kerala', '101'), -- State
    ('4029', 'Jammu and Kashmir', '101'), -- Union Territory (Status changed 2019)
    ('4030', 'Gujarat', '101'), -- State
    ('4031', 'Chandigarh', '101'), -- Union Territory
    (
        '4032',
        'Dadra and Nagar Haveli and Daman and Diu',
        '101'
    ), -- Changed Dadra and Nagar Haveli to merged UT name (Union Territory - Merged 2020)
    (
        '4033',
        'Dadra and Nagar Haveli and Daman and Diu',
        '101'
    ), -- Changed Daman and Diu to merged UT name (Duplicate entry, merged 2020) - Consider removing.
    ('4034', 'Sikkim', '101'), -- State
    ('4035', 'Tamil Nadu', '101'), -- State
    ('4036', 'Mizoram', '101'), -- State
    ('4037', 'Bihar', '101'), -- State
    ('4038', 'Tripura', '101'), -- State
    ('4039', 'Madhya Pradesh', '101'), -- State
    ('4040', 'Chhattisgarh', '101'), -- State
    ('4041', 'Choluteca Department', '97'), -- Honduras (Departamento)
    ('4042', 'Comayagua Department', '97'), -- Departamento
    ('4043', 'El Paraíso Department', '97'), -- Departamento
    ('4044', 'Intibucá Department', '97'), -- Departamento
    ('4045', 'Bay Islands Department', '97'), -- Islas de la Bahía (Departamento)
    ('4046', 'Cortés Department', '97'), -- Departamento
    ('4047', 'Atlántida Department', '97'), -- Departamento
    ('4048', 'Gracias a Dios Department', '97'), -- Departamento
    ('4049', 'Copán Department', '97'), -- Departamento
    ('4050', 'Olancho Department', '97'), -- Departamento
    ('4051', 'Colón Department', '97'), -- Departamento
    ('4052', 'Francisco Morazán Department', '97'), -- Departamento (Capital)
    ('4053', 'Santa Bárbara Department', '97'), -- Departamento
    ('4054', 'Lempira Department', '97'), -- Departamento
    ('4055', 'Valle Department', '97'), -- Departamento
    ('4056', 'Ocotepeque Department', '97'), -- Departamento
    ('4057', 'Yoro Department', '97'), -- Departamento
    ('4058', 'La Paz Department', '97'), -- Departamento
    ('4059', 'Northland Region', '158'), -- New Zealand
    ('4060', 'Manawatū-Whanganui Region', '158'), -- Changed Manawatu-Wanganui to Manawatū-Whanganui Region (Fixed char)
    ('4061', 'Waikato Region', '158'),
    ('4062', 'Otago Region', '158'),
    ('4063', 'Marlborough Region', '158'), -- (Unitary Authority)
    ('4064', 'West Coast Region', '158'),
    ('4065', 'Wellington Region', '158'), -- (Greater Wellington)
    ('4066', 'Canterbury Region', '158'),
    ('4067', 'Chatham Islands Territory', '158'), -- Changed Chatham Islands to Chatham Islands Territory (Special Territory Authority)
    ('4068', 'Gisborne District', '158'), -- (Unitary Authority)
    ('4069', 'Taranaki Region', '158'),
    ('4070', 'Nelson Region', '158'), -- (Unitary Authority)
    ('4071', 'Southland Region', '158'), -- (Includes Stewart Island/Rakiura)
    ('4072', 'Auckland Region', '158'), -- (Unitary Authority)
    ('4073', 'Tasman District', '158'), -- (Unitary Authority)
    ('4074', 'Bay of Plenty Region', '158'),
    ('4075', 'Hawke''s Bay Region', '158'), -- Fixed escaping
    ('4076', 'Saint John Parish', '61'), -- Dominica
    ('4077', 'Saint Mark Parish', '61'),
    ('4078', 'Saint David Parish', '61'),
    ('4079', 'Saint George Parish', '61'), -- (Capital parish - Roseau)
    ('4080', 'Saint Patrick Parish', '61'),
    ('4081', 'Saint Peter Parish', '61'),
    ('4082', 'Saint Andrew Parish', '61'),
    ('4083', 'Saint Luke Parish', '61'),
    ('4084', 'Saint Paul Parish', '61'),
    ('4085', 'Saint Joseph Parish', '61'),
    ('4086', 'El Seibo Province', '62'), -- Dominican Republic (Provincia)
    ('4087', 'La Romana Province', '62'), -- Provincia
    ('4088', 'Sánchez Ramírez Province', '62'), -- Sánchez has 'á', Ramírez has 'í' (Provincia)
    ('4089', 'Hermanas Mirabal Province', '62'), -- Provincia (Formerly Salcedo)
    ('4090', 'Barahona Province', '62'), -- Provincia
    ('4091', 'San Cristóbal Province', '62'), -- San Cristóbal has 'ó' (Provincia)
    ('4092', 'Puerto Plata Province', '62'), -- Provincia
    ('4093', 'Santo Domingo Province', '62'), -- Provincia
    ('4094', 'María Trinidad Sánchez Province', '62'), -- María Trinidad Sánchez has 'í', 'á' (Provincia)
    ('4095', 'Distrito Nacional', '62'), -- National District (Capital - Santo Domingo)
    ('4096', 'Peravia Province', '62'), -- Provincia
    ('4097', 'Independencia Province', '62'), -- Changed Independencia to Independencia Province (Provincia)
    ('4098', 'San Juan Province', '62'), -- Provincia
    ('4099', 'Monseñor Nouel Province', '62'), -- Monseñor has 'ñ' (Provincia)
    ('4100', 'Santiago Rodríguez Province', '62'), -- Santiago Rodríguez has 'í' (Provincia)
    ('4101', 'Pedernales Province', '62'), -- Provincia
    ('4102', 'Espaillat Province', '62'), -- Provincia
    ('4103', 'Samaná Province', '62'), -- Samaná has 'á' (Provincia)
    ('4104', 'Valverde Province', '62'), -- Provincia
    ('4105', 'Bahoruco Province', '62'), -- Changed Baoruco to Bahoruco Province (Provincia)
    ('4106', 'Hato Mayor Province', '62'), -- Provincia
    ('4107', 'Dajabón Province', '62'), -- Dajabón has 'ó' (Provincia)
    ('4108', 'Santiago Province', '62'), -- Provincia
    ('4109', 'La Altagracia Province', '62'), -- Provincia
    ('4110', 'San Pedro de Macorís Province', '62'), -- Changed San Pedro de Macorís to San Pedro de Macorís Province, Macorís has 'í' (Provincia)
    ('4111', 'Monte Plata Province', '62'), -- Provincia
    ('4112', 'San José de Ocoa Province', '62'), -- San José has 'é' (Provincia)
    ('4113', 'Duarte Province', '62'), -- Provincia
    ('4114', 'Azua Province', '62'), -- Provincia
    ('4115', 'Monte Cristi Province', '62'), -- Provincia
    ('4116', 'La Vega Province', '62'), -- Provincia
    ('4117', 'Nord Department', '95'), -- Haiti (Département)
    ('4118', 'Nippes Department', '95'), -- Changed Nippes to Nippes Department (Département)
    ('4119', 'Grand''Anse Department', '95'), -- Fixed escaping (Département)
    ('4120', 'Ouest Department', '95'), -- Département (Capital)
    ('4121', 'Nord-Est Department', '95'), -- Département
    ('4122', 'Sud Department', '95'), -- Changed Sud to Sud Department (Département)
    ('4123', 'Artibonite Department', '95'), -- Département
    ('4124', 'Sud-Est Department', '95'), -- Département
    ('4125', 'Centre Department', '95'), -- Changed Centre to Centre Department (Département)
    ('4126', 'Nord-Ouest Department', '95'), -- Département
    ('4127', 'San Vicente Department', '66'), -- El Salvador (Departamento)
    ('4128', 'Santa Ana Department', '66'), -- Departamento
    ('4129', 'Usulután Department', '66'), -- Usulután has 'á' (Departamento)
    ('4130', 'Morazán Department', '66'), -- Morazán has 'á' (Departamento)
    ('4131', 'Chalatenango Department', '66'), -- Departamento
    ('4132', 'Cabañas Department', '66'), -- Departamento
    ('4133', 'San Salvador Department', '66'), -- Departamento (Capital)
    ('4134', 'La Libertad Department', '66'), -- Departamento
    ('4135', 'San Miguel Department', '66'), -- Departamento
    ('4136', 'La Paz Department', '66'), -- Departamento
    ('4137', 'Cuscatlán Department', '66'), -- Cuscatlán has 'á' (Departamento)
    ('4138', 'La Unión Department', '66'), -- La Unión has 'ó' (Departamento)
    ('4139', 'Ahuachapán Department', '66'), -- Ahuachapán has 'á' (Departamento)
    ('4140', 'Sonsonate Department', '66'), -- Departamento
    ('4141', 'Braslovče Municipality', '201'), -- Slovenia (Občina)
    ('4142', 'Lenart Municipality', '201'), -- Občina
    ('4143', 'Oplotnica Municipality', '201'), -- Changed Oplotnica to Oplotnica Municipality (Občina)
    ('4144', 'Velike Lašče Municipality', '201'), -- Velike Lašče has 'š', 'č' (Občina)
    ('4145', 'Hajdina Municipality', '201'), -- Občina
    ('4146', 'Podčetrtek Municipality', '201'), -- Podčetrtek has 'č' (Občina)
    ('4147', 'Cankova Municipality', '201'), -- Občina
    ('4148', 'Vitanje Municipality', '201'), -- Občina
    ('4149', 'Sežana Municipality', '201'), -- Sežana has 'ž' (Občina)
    ('4150', 'Kidričevo Municipality', '201'), -- Kidričevo has 'č' (Občina)
    ('4151', 'Črenšovci Municipality', '201'), -- Črenšovci has 'Č', 'š' (Občina)
    ('4152', 'Idrija Municipality', '201'), -- Občina
    ('4153', 'Trnovska Vas Municipality', '201'), -- Občina
    ('4154', 'Vodice Municipality', '201'), -- Občina
    ('4155', 'Ravne na Koroškem Municipality', '201'), -- Koroškem has 'š' (Občina)
    ('4156', 'Lovrenc na Pohorju Municipality', '201'), -- Občina
    ('4157', 'Majšperk Municipality', '201'), -- Majšperk has 'š' (Občina)
    ('4158', 'Loški Potok Municipality', '201'), -- Loški Potok has 'š' (Občina)
    ('4159', 'Domžale Municipality', '201'), -- Domžale has 'ž' (Občina)
    ('4160', 'Rečica ob Savinji Municipality', '201'), -- Rečica has 'č' (Občina)
    ('4161', 'Podlehnik Municipality', '201'), -- Občina
    ('4162', 'Cerknica Municipality', '201'), -- Občina
    ('4163', 'Vransko Municipality', '201'), -- Občina
    ('4164', 'Sveta Ana Municipality', '201'), -- Občina
    ('4165', 'Brezovica Municipality', '201'), -- Občina
    ('4166', 'Benedikt Municipality', '201'), -- Občina
    ('4167', 'Divača Municipality', '201'), -- Divača has 'č' (Občina)
    ('4168', 'Moravče Municipality', '201'), -- Moravče has 'č' (Občina)
    ('4169', 'Slovenj Gradec City Municipality', '201'), -- Mestna občina
    ('4170', 'Škocjan Municipality', '201'), -- Škocjan has 'Š' (Občina)
    ('4171', 'Šentjur Municipality', '201'), -- Šentjur has 'Š' (Občina)
    ('4172', 'Pesnica Municipality', '201'), -- Občina
    ('4173', 'Dol pri Ljubljani Municipality', '201'), -- Občina
    ('4174', 'Loška Dolina Municipality', '201'), -- Loška has 'š' (Občina)
    ('4175', 'Hoče–Slivnica Municipality', '201'), -- Hoče has 'č' (Občina)
    ('4176', 'Cerkvenjak Municipality', '201'), -- Občina
    ('4177', 'Naklo Municipality', '201'), -- Občina
    ('4178', 'Cerkno Municipality', '201'), -- Občina
    ('4179', 'Bistrica ob Sotli Municipality', '201'), -- Občina
    ('4180', 'Kamnik Municipality', '201'), -- Občina
    ('4181', 'Bovec Municipality', '201'), -- Občina
    ('4182', 'Zavrč Municipality', '201'), -- Zavrč has 'č' (Občina)
    ('4183', 'Ajdovščina Municipality', '201'), -- Ajdovščina has 'š' (Občina)
    ('4184', 'Pivka Municipality', '201'), -- Občina
    ('4185', 'Štore Municipality', '201'), -- Štore has 'Š' (Občina)
    ('4186', 'Kozje Municipality', '201'), -- Občina
    ('4187', 'Škofljica Municipality', '201'), -- Changed Municipality of Škofljica to Škofljica Municipality, Škofljica has 'Š' (Občina)
    ('4188', 'Prebold Municipality', '201'), -- Občina
    ('4189', 'Dobrovnik Municipality', '201'), -- Občina
    ('4190', 'Mozirje Municipality', '201'), -- Občina
    ('4191', 'Celje City Municipality', '201'), -- Changed City Municipality of Celje to Celje City Municipality (Mestna občina)
    ('4192', 'Žiri Municipality', '201'), -- Žiri has 'Ž' (Občina)
    ('4193', 'Horjul Municipality', '201'), -- Občina
    ('4194', 'Tabor Municipality', '201'), -- Občina
    ('4195', 'Radeče Municipality', '201'), -- Radeče has 'č' (Občina)
    ('4196', 'Vipava Municipality', '201'), -- Občina
    ('4197', 'Kungota Municipality', '201'), -- Changed Kungota to Kungota Municipality (Občina)
    ('4198', 'Slovenske Konjice Municipality', '201'), -- Občina
    ('4199', 'Osilnica Municipality', '201'), -- Občina
    ('4200', 'Borovnica Municipality', '201'), -- Občina
    ('4201', 'Piran Municipality', '201'), -- Občina
    ('4202', 'Bled Municipality', '201'), -- Občina
    ('4203', 'Jezersko Municipality', '201'), -- Občina
    ('4204', 'Rače–Fram Municipality', '201'), -- Rače has 'č' (Občina)
    ('4205', 'Nova Gorica City Municipality', '201'), -- Mestna občina
    ('4206', 'Razkrižje Municipality', '201'), -- Razkrižje has 'ž' (Občina)
    ('4207', 'Ribnica na Pohorju Municipality', '201'), -- Občina
    ('4208', 'Muta Municipality', '201'), -- Občina
    ('4209', 'Rogatec Municipality', '201'), -- Občina
    ('4210', 'Gorišnica Municipality', '201'), -- Gorišnica has 'š' (Občina)
    ('4211', 'Kuzma Municipality', '201'), -- Občina
    ('4212', 'Mislinja Municipality', '201'), -- Občina
    ('4213', 'Duplek Municipality', '201'), -- Občina
    ('4214', 'Trebnje Municipality', '201'), -- Občina
    ('4215', 'Brežice Municipality', '201'), -- Brežice has 'ž' (Občina)
    ('4216', 'Dobrepolje Municipality', '201'), -- Občina
    ('4217', 'Grad Municipality', '201'), -- Občina
    ('4218', 'Moravske Toplice Municipality', '201'), -- Občina
    ('4219', 'Luče Municipality', '201'), -- Luče has 'č' (Občina)
    ('4220', 'Miren–Kostanjevica Municipality', '201'), -- Občina
    ('4221', 'Ormož Municipality', '201'), -- Občina
    ('4222', 'Šalovci Municipality', '201'), -- Šalovci has 'Š' (Občina)
    (
        '4223',
        'Miklavž na Dravskem Polju Municipality',
        '201'
    ), -- Miklavž has 'ž' (Občina)
    ('4224', 'Makole Municipality', '201'), -- Občina
    ('4225', 'Lendava Municipality', '201'), -- Občina
    ('4226', 'Vuzenica Municipality', '201'), -- Občina
    ('4227', 'Kanal ob Soči Municipality', '201'), -- Soči has 'č' (Občina)
    ('4228', 'Ptuj City Municipality', '201'), -- Mestna občina
    (
        '4229',
        'Sveti Andraž v Slovenskih Goricah Municipality',
        '201'
    ), -- Andraž has 'ž' (Občina)
    ('4230', 'Selnica ob Dravi Municipality', '201'), -- Občina
    ('4231', 'Radovljica Municipality', '201'), -- Občina
    ('4232', 'Črna na Koroškem Municipality', '201'), -- Črna has 'Č', Koroškem has 'š' (Občina)
    ('4233', 'Rogaška Slatina Municipality', '201'), -- Rogaška has 'š' (Občina)
    ('4234', 'Podvelka Municipality', '201'), -- Občina
    ('4235', 'Ribnica Municipality', '201'), -- Občina
    ('4236', 'Novo Mesto City Municipality', '201'), -- Changed City Municipality of Novo Mesto to Novo Mesto City Municipality (Mestna občina)
    ('4237', 'Mirna Peč Municipality', '201'), -- Mirna Peč has 'č' (Občina)
    ('4238', 'Križevci Municipality', '201'), -- Občina
    ('4239', 'Poljčane Municipality', '201'), -- Poljčane has 'č' (Občina)
    ('4240', 'Brda Municipality', '201'), -- Občina
    ('4241', 'Šentjernej Municipality', '201'), -- Šentjernej has 'Š' (Občina)
    ('4242', 'Maribor City Municipality', '201'), -- Mestna občina
    ('4243', 'Kobarid Municipality', '201'), -- Občina
    ('4244', 'Markovci Municipality', '201'), -- Občina
    ('4245', 'Vojnik Municipality', '201'), -- Občina
    ('4246', 'Trbovlje Municipality', '201'), -- Občina
    ('4247', 'Tolmin Municipality', '201'), -- Občina
    ('4248', 'Šoštanj Municipality', '201'), -- Šoštanj has 'Š', 'š' (Občina)
    ('4249', 'Žetale Municipality', '201'), -- Žetale has 'Ž' (Občina)
    ('4250', 'Tržič Municipality', '201'), -- Tržič has 'č' (Občina)
    ('4251', 'Turnišče Municipality', '201'), -- Turnišče has 'š', 'č' (Občina)
    ('4252', 'Dobrna Municipality', '201'), -- Občina
    ('4253', 'Renče–Vogrsko Municipality', '201'), -- Renče has 'č' (Občina)
    (
        '4254',
        'Kostanjevica na Krki Municipality',
        '201'
    ), -- Občina
    (
        '4255',
        'Sveti Jurij ob Ščavnici Municipality',
        '201'
    ), -- Ščavnici has 'Š', 'č' (Občina)
    ('4256', 'Železniki Municipality', '201'), -- Železniki has 'Ž' (Občina)
    ('4257', 'Veržej Municipality', '201'), -- Veržej has 'ž' (Občina)
    ('4258', 'Žalec Municipality', '201'), -- Žalec has 'Ž' (Občina)
    ('4259', 'Starše Municipality', '201'), -- Starše has 'š' (Občina)
    (
        '4260',
        'Sveta Trojica v Slovenskih Goricah Municipality',
        '201'
    ), -- Trojica has 'č' (Občina)
    ('4261', 'Solčava Municipality', '201'), -- Solčava has 'č' (Občina)
    ('4262', 'Vrhnika Municipality', '201'), -- Občina
    ('4263', 'Središče ob Dravi Municipality', '201'), -- Središče has 'š', 'č' (Občina)
    ('4264', 'Rogašovci Municipality', '201'), -- Rogašovci has 'š' (Občina)
    ('4265', 'Mežica Municipality', '201'), -- Mežica has 'ž' (Občina)
    ('4266', 'Juršinci Municipality', '201'), -- Juršinci has 'š' (Občina)
    ('4267', 'Velika Polana Municipality', '201'), -- Občina
    ('4268', 'Sevnica Municipality', '201'), -- Občina
    ('4269', 'Zagorje ob Savi Municipality', '201'), -- Občina
    ('4270', 'Ljubljana City Municipality', '201'), -- Mestna občina (Capital)
    ('4271', 'Gornji Petrovci Municipality', '201'), -- Občina
    ('4272', 'Polzela Municipality', '201'), -- Občina
    ('4273', 'Sveti Tomaž Municipality', '201'), -- Tomaž has 'ž' (Občina)
    ('4274', 'Prevalje Municipality', '201'), -- Občina
    ('4275', 'Radlje ob Dravi Municipality', '201'), -- Občina
    ('4276', 'Žirovnica Municipality', '201'), -- Žirovnica has 'Ž' (Občina)
    ('4277', 'Sodražica Municipality', '201'), -- Sodražica has 'ž' (Občina)
    ('4278', 'Bloke Municipality', '201'), -- Občina
    ('4279', 'Šmartno pri Litiji Municipality', '201'), -- Šmartno has 'Š' (Občina)
    ('4280', 'Ruše Municipality', '201'), -- Ruše has 'š' (Občina)
    ('4281', 'Dolenjske Toplice Municipality', '201'), -- Občina
    ('4282', 'Bohinj Municipality', '201'), -- Občina
    ('4283', 'Komenda Municipality', '201'), -- Občina
    ('4284', 'Gorje Municipality', '201'), -- Občina
    ('4285', 'Šmarje pri Jelšah Municipality', '201'), -- Šmarje has 'Š', Jelšah has 'š' (Občina)
    ('4286', 'Ig Municipality', '201'), -- Občina
    ('4287', 'Kranj City Municipality', '201'), -- Mestna občina
    ('4288', 'Puconci Municipality', '201'), -- Občina
    ('4289', 'Šmarješke Toplice Municipality', '201'), -- Šmarješke has 'Š', 'š' (Občina)
    ('4290', 'Dornava Municipality', '201'), -- Občina
    ('4291', 'Črnomelj Municipality', '201'), -- Črnomelj has 'Č' (Občina)
    ('4292', 'Radenci Municipality', '201'), -- Občina
    ('4293', 'Gorenja Vas–Poljane Municipality', '201'), -- Občina
    ('4294', 'Ljubno Municipality', '201'), -- Občina
    ('4295', 'Dobje Municipality', '201'), -- Občina
    ('4296', 'Šmartno ob Paki Municipality', '201'), -- Šmartno has 'Š' (Občina)
    ('4297', 'Mokronog–Trebelno Municipality', '201'), -- Občina
    ('4298', 'Mirna Municipality', '201'), -- Občina
    ('4299', 'Šenčur Municipality', '201'), -- Šenčur has 'Š', 'č' (Občina)
    ('4300', 'Videm Municipality', '201'), -- Občina
    ('4301', 'Beltinci Municipality', '201'), -- Občina
    ('4302', 'Lukovica Municipality', '201'), -- Občina
    ('4303', 'Preddvor Municipality', '201'), -- Občina
    ('4304', 'Destrnik Municipality', '201'), -- Občina
    ('4305', 'Ivančna Gorica Municipality', '201'), -- Ivančna Gorica has 'č' (Občina)
    ('4306', 'Log–Dragomer Municipality', '201'), -- Občina
    ('4307', 'Žužemberk Municipality', '201'), -- Žužemberk has 'Ž', 'ž' (Občina)
    (
        '4308',
        'Dobrova–Polhov Gradec Municipality',
        '201'
    ), -- Občina
    ('4309', 'Cirkulane Municipality', '201'), -- Changed Municipality of Cirkulane to Cirkulane Municipality (Občina)
    (
        '4310',
        'Cerklje na Gorenjskem Municipality',
        '201'
    ), -- Občina
    ('4311', 'Šentrupert Municipality', '201'), -- Šentrupert has 'Š' (Občina)
    ('4312', 'Tišina Municipality', '201'), -- Tišina has 'š' (Občina)
    ('4313', 'Murska Sobota City Municipality', '201'), -- Mestna občina
    ('4314', 'Krško Municipality', '201'), -- Changed Municipality of Krško to Krško Municipality, Krško has 'š' (Občina)
    ('4315', 'Komen Municipality', '201'), -- Občina
    ('4316', 'Škofja Loka Municipality', '201'), -- Škofja Loka has 'Š' (Občina)
    ('4317', 'Šempeter–Vrtojba Municipality', '201'), -- Šempeter has 'Š' (Občina)
    ('4318', 'Apače Municipality', '201'), -- Changed Municipality of Apače to Apače Municipality, Apače has 'č' (Občina)
    ('4319', 'Koper City Municipality', '201'), -- Mestna občina
    ('4320', 'Odranci Municipality', '201'), -- Občina
    ('4321', 'Hrpelje–Kozina Municipality', '201'), -- Občina
    ('4322', 'Izola Municipality', '201'), -- Občina
    ('4323', 'Metlika Municipality', '201'), -- Občina
    ('4324', 'Šentilj Municipality', '201'), -- Šentilj has 'Š' (Občina)
    ('4325', 'Kobilje Municipality', '201'), -- Občina
    ('4326', 'Ankaran Municipality', '201'), -- Občina
    ('4327', 'Hodoš Municipality', '201'), -- Občina
    (
        '4328',
        'Sveti Jurij v Slovenskih Goricah Municipality',
        '201'
    ), -- Občina
    ('4329', 'Nazarje Municipality', '201'), -- Občina
    ('4330', 'Postojna Municipality', '201'), -- Občina
    ('4331', 'Kostel Municipality', '201'), -- Občina
    ('4332', 'Slovenska Bistrica Municipality', '201'), -- Občina
    ('4333', 'Straža Municipality', '201'), -- Straža has 'ž' (Občina)
    ('4334', 'Trzin Municipality', '201'), -- Občina
    ('4335', 'Kočevje Municipality', '201'), -- Kočevje has 'č' (Občina)
    ('4336', 'Grosuplje Municipality', '201'), -- Občina
    ('4337', 'Jesenice Municipality', '201'), -- Občina
    ('4338', 'Laško Municipality', '201'), -- Laško has 'š' (Občina)
    ('4339', 'Gornji Grad Municipality', '201'), -- Občina
    ('4340', 'Kranjska Gora Municipality', '201'), -- Občina
    ('4341', 'Hrastnik Municipality', '201'), -- Občina
    ('4342', 'Zreče Municipality', '201'), -- Zreče has 'č' (Občina)
    ('4343', 'Gornja Radgona Municipality', '201'), -- Občina
    ('4344', 'Ilirska Bistrica Municipality', '201'), -- Changed Municipality of Ilirska Bistrica to Ilirska Bistrica Municipality (Občina)
    ('4345', 'Dravograd Municipality', '201'), -- Občina
    ('4346', 'Semič Municipality', '201'), -- Semič has 'č' (Občina)
    ('4347', 'Litija Municipality', '201'), -- Občina
    ('4348', 'Mengeš Municipality', '201'), -- Mengeš has 'š' (Občina)
    ('4349', 'Medvode Municipality', '201'), -- Občina
    ('4350', 'Logatec Municipality', '201'), -- Občina
    ('4351', 'Ljutomer Municipality', '201'), -- Občina
    ('4352', 'Banská Bystrica Region', '200'), -- Slovakia (Kraj)
    ('4353', 'Košice Region', '200'), -- Košice has 'š' (Kraj)
    ('4354', 'Prešov Region', '200'), -- Prešov has 'š' (Kraj)
    ('4355', 'Trnava Region', '200'), -- Kraj
    ('4356', 'Bratislava Region', '200'), -- Kraj (Capital)
    ('4357', 'Nitra Region', '200'), -- Kraj
    ('4358', 'Trenčín Region', '200'), -- Trenčín has 'č' (Kraj)
    ('4359', 'Žilina Region', '200'), -- Žilina has 'Ž' (Kraj)
    ('4360', 'Cimișlia District', '144'), -- Moldova (Raion), Cimișlia has 'ș'
    ('4361', 'Orhei District', '144'), -- Raion
    ('4362', 'Bender Municipality', '144'), -- Municipality (Tighina - De jure part of Moldova, de facto controlled by Transnistria)
    ('4363', 'Nisporeni District', '144'), -- Raion
    ('4364', 'Sîngerei District', '144'), -- Sîngerei has 'î' (Raion)
    ('4365', 'Căușeni District', '144'), -- Căușeni has 'ș' (Raion)
    ('4366', 'Călărași District', '144'), -- Călărași has 'ă', 'ș' (Raion)
    ('4367', 'Glodeni District', '144'), -- Raion
    ('4368', 'Anenii Noi District', '144'), -- Raion
    ('4369', 'Ialoveni District', '144'), -- Raion
    ('4370', 'Florești District', '144'), -- Florești has 'ș' (Raion)
    ('4371', 'Telenești District', '144'), -- Telenești has 'ș' (Raion)
    ('4372', 'Taraclia District', '144'), -- Raion
    ('4373', 'Chișinău Municipality', '144'), -- Chișinău has 'ș', 'ă' (Municipiu - Capital)
    ('4374', 'Soroca District', '144'), -- Raion
    ('4375', 'Briceni District', '144'), -- Raion
    ('4376', 'Rîșcani District', '144'), -- Rîșcani has 'î', 'ș' (Raion)
    ('4377', 'Strășeni District', '144'), -- Strășeni has 'ș' (Raion)
    ('4378', 'Ștefan Vodă District', '144'), -- Ștefan Vodă has 'Ș', 'ă' (Raion)
    ('4379', 'Basarabeasca District', '144'), -- Raion
    ('4380', 'Cantemir District', '144'), -- Raion
    ('4381', 'Fălești District', '144'), -- Fălești has 'ă', 'ș' (Raion)
    ('4382', 'Hîncești District', '144'), -- Hîncești has 'î', 'ș' (Raion)
    ('4383', 'Dubăsari District', '144'), -- Dubăsari has 'ă' (Raion - Part de facto controlled by Transnistria)
    ('4384', 'Dondușeni District', '144'), -- Dondușeni has 'ș' (Raion)
    (
        '4385',
        'Gagauzia Autonomous Territorial Unit',
        '144'
    ), -- Changed Gagauzia to Gagauzia Autonomous Territorial Unit (Găgăuzia - UTA)
    ('4386', 'Ungheni District', '144'), -- Raion
    ('4387', 'Edineț District', '144'), -- Edineț has 'ț' (Raion)
    ('4388', 'Șoldănești District', '144'), -- Șoldănești has 'Ș', 'ă', 'ș' (Raion)
    ('4389', 'Ocnița District', '144'), -- Ocnița has 'ț' (Raion)
    ('4390', 'Criuleni District', '144'), -- Raion
    ('4391', 'Cahul District', '144'), -- Raion
    ('4392', 'Drochia District', '144'), -- Raion
    ('4393', 'Bălți Municipality', '144'), -- Bălți has 'ă', 'ț' (Municipiu)
    ('4394', 'Rezina District', '144'), -- Raion
    (
        '4395',
        'Administrative-Territorial Units of the Left Bank of the Dniester',
        '144'
    ), -- Changed Transnistria autonomous territorial unit to official Moldova designation for Transnistria region (De facto independent)
    (
        '4396',
        'Salacgrīva Municipality (historical)',
        '120'
    ), -- Latvia (Novads) - Merged into Limbaži Municipality 2021
    (
        '4397',
        'Vecumnieki Municipality (historical)',
        '120'
    ), -- Merged into Bauska Municipality 2021
    (
        '4398',
        'Naukšēni Municipality (historical)',
        '120'
    ), -- Naukšēni has 'š' - Merged into Valmiera Municipality 2021
    (
        '4399',
        'Ilūkste Municipality (historical)',
        '120'
    ), -- Ilūkste has 'ū' - Merged into Augšdaugava Municipality 2021
    ('4400', 'Gulbene Municipality', '120'), -- Novads
    ('4401', 'Līvāni Municipality', '120'), -- Līvāni has 'ī', 'ā' (Novads)
    ('4402', 'Salaspils Municipality', '120'), -- Novads
    ('4403', 'Ventspils Municipality', '120'), -- Novads
    (
        '4404',
        'Rundāle Municipality (historical)',
        '120'
    ), -- Rundāle has 'ā' - Merged into Bauska Municipality 2021
    (
        '4405',
        'Pļaviņas Municipality (historical)',
        '120'
    ), -- Pļaviņas has 'ļ', 'ņ' - Merged into Aizkraukle Municipality 2021
    (
        '4406',
        'Vārkava Municipality (historical)',
        '120'
    ), -- Vārkava has 'ā' - Merged into Preiļi Municipality 2021
    (
        '4407',
        'Jaunpiebalga Municipality (historical)',
        '120'
    ), -- Merged into Cēsis Municipality 2021
    ('4408', 'Sēja Municipality (historical)', '120'), -- Sēja has 'ē' - Merged into Saulkrasti Municipality 2021
    ('4409', 'Tukums Municipality', '120'), -- Novads
    ('4410', 'Cibla Municipality (historical)', '120'), -- Merged into Ludza Municipality 2021
    (
        '4411',
        'Burtnieki Municipality (historical)',
        '120'
    ), -- Merged into Valmiera Municipality 2021
    ('4412', 'Ķegums Municipality (historical)', '120'), -- Ķegums has 'Ķ' - Merged into Ogre Municipality 2021
    (
        '4413',
        'Krustpils Municipality (historical)',
        '120'
    ), -- Merged into Jēkabpils Municipality 2021
    (
        '4414',
        'Cesvaine Municipality (historical)',
        '120'
    ), -- Merged into Madona Municipality 2021
    (
        '4415',
        'Skrīveri Municipality (historical)',
        '120'
    ), -- Skrīveri has 'ī' - Merged into Aizkraukle Municipality 2021
    ('4416', 'Ogre Municipality', '120'), -- Novads
    ('4417', 'Olaine Municipality', '120'), -- Novads
    ('4418', 'Limbaži Municipality', '120'), -- Limbaži has 'ž' (Novads)
    ('4419', 'Lubāna Municipality (historical)', '120'), -- Lubāna has 'ā' - Merged into Madona Municipality 2021
    (
        '4420',
        'Kandava Municipality (historical)',
        '120'
    ), -- Merged into Tukums Municipality 2021
    ('4421', 'Ventspils State City', '120'), -- Changed Ventspils to Ventspils State City (Valstspilsēta)
    (
        '4422',
        'Krimulda Municipality (historical)',
        '120'
    ), -- Merged into Sigulda Municipality 2021
    ('4423', 'Rugāji Municipality (historical)', '120'), -- Rugāji has 'ā' - Merged into Balvi Municipality 2021
    ('4424', 'Jelgava Municipality', '120'), -- Novads
    ('4425', 'Valka Municipality', '120'), -- Novads
    (
        '4426',
        'Rūjiena Municipality (historical)',
        '120'
    ), -- Rūjiena has 'ū' - Merged into Valmiera Municipality 2021
    ('4427', 'Babīte Municipality (historical)', '120'), -- Babīte has 'ī' - Merged into Mārupe Municipality 2021
    (
        '4428',
        'Dundaga Municipality (historical)',
        '120'
    ), -- Merged into Talsi Municipality 2021
    (
        '4429',
        'Priekule Municipality (historical)',
        '120'
    ), -- Merged into South Kurzeme Municipality 2021
    ('4430', 'Zilupe Municipality (historical)', '120'), -- Merged into Ludza Municipality 2021
    ('4431', 'Varakļāni Municipality', '120'), -- Varakļāni has 'ļ', 'ā' (Novads - Remained separate after 2021 reform)
    ('4432', 'Nereta Municipality (historical)', '120'), -- Merged into Aizkraukle Municipality 2021
    ('4433', 'Madona Municipality', '120'), -- Novads
    ('4434', 'Sala Municipality (historical)', '120'), -- Merged into Jēkabpils Municipality 2021
    ('4435', 'Ķekava Municipality', '120'), -- Ķekava has 'Ķ' (Novads)
    ('4436', 'Nīca Municipality (historical)', '120'), -- Nīca has 'ī' - Merged into South Kurzeme Municipality 2021
    ('4437', 'Dobele Municipality', '120'), -- Novads
    ('4438', 'Jēkabpils Municipality', '120'), -- Novads
    ('4439', 'Saldus Municipality', '120'), -- Novads
    ('4440', 'Roja Municipality (historical)', '120'), -- Merged into Talsi Municipality 2021
    ('4441', 'Iecava Municipality (historical)', '120'), -- Merged into Bauska Municipality 2021
    (
        '4442',
        'Ozolnieki Municipality (historical)',
        '120'
    ), -- Merged into Jelgava Municipality 2021
    ('4443', 'Saulkrasti Municipality', '120'), -- Novads
    ('4444', 'Ērgļi Municipality (historical)', '120'), -- Ērgļi has 'Ē' - Merged into Madona Municipality 2021
    ('4445', 'Aglona Municipality (historical)', '120'), -- Merged into Preiļi and Krāslava Municipalities 2021
    ('4446', 'Jūrmala State City', '120'), -- Changed Jūrmala to Jūrmala State City (Jūrmala has 'ū' - Valstspilsēta)
    (
        '4447',
        'Skrunda Municipality (historical)',
        '120'
    ), -- Merged into Kuldīga Municipality 2021
    ('4448', 'Engure Municipality (historical)', '120'), -- Merged into Tukums Municipality 2021
    (
        '4449',
        'Inčukalns Municipality (historical)',
        '120'
    ), -- Inčukalns has 'č' - Merged into Sigulda Municipality 2021
    ('4450', 'Mārupe Municipality', '120'), -- Mārupe has 'ā' (Novads)
    (
        '4451',
        'Mērsrags Municipality (historical)',
        '120'
    ), -- Mērsrags has 'ē' - Merged into Talsi Municipality 2021
    (
        '4452',
        'Koknese Municipality (historical)',
        '120'
    ), -- Merged into Aizkraukle Municipality 2021
    (
        '4453',
        'Kārsava Municipality (historical)',
        '120'
    ), -- Kārsava has 'ā' - Merged into Ludza Municipality 2021
    (
        '4454',
        'Carnikava Municipality (historical)',
        '120'
    ), -- Merged into Ādaži Municipality 2021
    ('4455', 'Rēzekne Municipality', '120'), -- Rēzekne has 'ē' (Novads)
    (
        '4456',
        'Viesīte Municipality (historical)',
        '120'
    ), -- Viesīte has 'ī' - Merged into Jēkabpils Municipality 2021
    ('4457', 'Ape Municipality (historical)', '120'), -- Merged into Smiltene Municipality 2021
    ('4458', 'Durbe Municipality (historical)', '120'), -- Merged into South Kurzeme Municipality 2021
    ('4459', 'Talsi Municipality', '120'), -- Novads
    ('4460', 'Liepāja State City', '120'), -- Changed Liepāja to Liepāja State City (Liepāja has 'ā' - Valstspilsēta)
    (
        '4461',
        'Mālpils Municipality (historical)',
        '120'
    ), -- Mālpils has 'ā' - Merged into Sigulda Municipality 2021
    ('4462', 'Smiltene Municipality', '120'), -- Novads
    ('4463', 'Daugavpils State City', '120'), -- Changed Daugavpils to Daugavpils State City (Valstspilsēta)
    ('4464', 'Jēkabpils State City', '120'), -- Changed Jēkabpils to Jēkabpils State City (Valstspilsēta)
    ('4465', 'Bauska Municipality', '120'), -- Novads
    (
        '4466',
        'Vecpiebalga Municipality (historical)',
        '120'
    ), -- Merged into Cēsis Municipality 2021
    (
        '4467',
        'Pāvilosta Municipality (historical)',
        '120'
    ), -- Pāvilosta has 'ā' - Merged into South Kurzeme Municipality 2021
    (
        '4468',
        'Brocēni Municipality (historical)',
        '120'
    ), -- Brocēni has 'ē' - Merged into Saldus Municipality 2021
    ('4469', 'Cēsis Municipality', '120'), -- Cēsis has 'ē' (Novads)
    (
        '4470',
        'Grobiņa Municipality (historical)',
        '120'
    ), -- Grobiņa has 'ņ' - Merged into South Kurzeme Municipality 2021
    (
        '4471',
        'Beverīna Municipality (historical)',
        '120'
    ), -- Beverīna has 'ī' - Merged into Valmiera Municipality 2021
    ('4472', 'Aizkraukle Municipality', '120'), -- Novads
    ('4473', 'Valmiera State City', '120'), -- Changed Valmiera to Valmiera State City (Valstspilsēta)
    ('4474', 'Krāslava Municipality', '120'), -- Krāslava has 'ā' (Novads)
    (
        '4475',
        'Jaunjelgava Municipality (historical)',
        '120'
    ), -- Merged into Aizkraukle Municipality 2021
    ('4476', 'Sigulda Municipality', '120'), -- Novads
    ('4477', 'Viļaka Municipality (historical)', '120'), -- Viļaka has 'ļ' - Merged into Balvi Municipality 2021
    (
        '4478',
        'Stopiņi Municipality (historical)',
        '120'
    ), -- Stopiņi has 'ņ' - Merged into Ropaži Municipality 2021
    ('4479', 'Rauna Municipality (historical)', '120'), -- Merged into Smiltene Municipality 2021
    (
        '4480',
        'Tērvete Municipality (historical)',
        '120'
    ), -- Tērvete has 'ē' - Merged into Dobele Municipality 2021
    ('4481', 'Auce Municipality (historical)', '120'), -- Merged into Dobele Municipality 2021
    (
        '4482',
        'Baldone Municipality (historical)',
        '120'
    ), -- Merged into Ķekava Municipality 2021
    ('4483', 'Preiļi Municipality', '120'), -- Preiļi has 'ļ' (Novads)
    ('4484', 'Aloja Municipality (historical)', '120'), -- Merged into Limbaži Municipality 2021
    (
        '4485',
        'Alsunga Municipality (historical)',
        '120'
    ), -- Merged into Kuldīga Municipality 2021
    ('4486', 'Viļāni Municipality (historical)', '120'), -- Viļāni has 'ļ', 'ā' - Merged into Rēzekne Municipality 2021
    ('4487', 'Alūksne Municipality', '120'), -- Alūksne has 'ū' (Novads)
    (
        '4488',
        'Līgatne Municipality (historical)',
        '120'
    ), -- Līgatne has 'ī' - Merged into Cēsis Municipality 2021
    (
        '4489',
        'Jaunpils Municipality (historical)',
        '120'
    ), -- Merged into Tukums Municipality 2021
    ('4490', 'Kuldīga Municipality', '120'), -- Kuldīga has 'ī' (Novads)
    ('4491', 'Riga State City', '120'), -- Changed Riga to Riga State City (Rīga has 'ī' - Valstspilsēta - Capital)
    ('4492', 'Augšdaugava Municipality', '120'), -- Changed Daugavpils Municipality to Augšdaugava Municipality (Novads - established 2021)
    ('4493', 'Ropaži Municipality', '120'), -- Ropaži has 'ž' (Novads)
    (
        '4494',
        'Strenči Municipality (historical)',
        '120'
    ), -- Strenči has 'č' - Merged into Valmiera Municipality 2021
    ('4495', 'Kocēni Municipality (historical)', '120'), -- Kocēni has 'ē' - Merged into Valmiera Municipality 2021
    (
        '4496',
        'Aizpute Municipality (historical)',
        '120'
    ), -- Merged into South Kurzeme Municipality 2021
    ('4497', 'Amata Municipality (historical)', '120'), -- Merged into Cēsis Municipality 2021
    (
        '4498',
        'Baltinava Municipality (historical)',
        '120'
    ), -- Merged into Balvi Municipality 2021
    (
        '4499',
        'Aknīste Municipality (historical)',
        '120'
    ), -- Aknīste has 'ī' - Merged into Jēkabpils Municipality 2021
    ('4500', 'Jelgava State City', '120'), -- Changed Jelgava to Jelgava State City (Valstspilsēta)
    ('4501', 'Ludza Municipality', '120'), -- Novads
    (
        '4502',
        'Riebiņi Municipality (historical)',
        '120'
    ), -- Riebiņi has 'ņ' - Merged into Preiļi Municipality 2021
    ('4503', 'Rucava Municipality (historical)', '120'), -- Merged into South Kurzeme Municipality 2021
    ('4504', 'Dagda Municipality (historical)', '120'), -- Merged into Krāslava Municipality 2021
    ('4505', 'Balvi Municipality', '120'), -- Novads
    (
        '4506',
        'Priekuļi Municipality (historical)',
        '120'
    ), -- Priekuļi has 'ļ' - Merged into Cēsis Municipality 2021
    (
        '4507',
        'Pārgauja Municipality (historical)',
        '120'
    ), -- Pārgauja has 'ā' - Merged into Cēsis Municipality 2021
    (
        '4508',
        'Vaiņode Municipality (historical)',
        '120'
    ), -- Vaiņode has 'ņ' - Merged into South Kurzeme Municipality 2021
    ('4509', 'Rēzekne State City', '120'), -- Changed Rēzekne to Rēzekne State City (Rēzekne has 'ē' - Valstspilsēta)
    (
        '4510',
        'Garkalne Municipality (historical)',
        '120'
    ), -- Merged into Ropaži Municipality 2021
    (
        '4511',
        'Ikšķile Municipality (historical)',
        '120'
    ), -- Ikšķile has 'š' - Merged into Ogre Municipality 2021
    (
        '4512',
        'Lielvārde Municipality (historical)',
        '120'
    ), -- Lielvārde has 'ā' - Merged into Ogre Municipality 2021
    (
        '4513',
        'Mazsalaca Municipality (historical)',
        '120'
    ), -- Merged into Valmiera Municipality 2021
    ('4514', 'Viqueque Municipality', '63'), -- East Timor (Município)
    ('4515', 'Liquiçá Municipality', '63'), -- Liquiçá has 'ç', 'á' (Município)
    ('4516', 'Ermera Municipality', '63'), -- Changed Ermera District to Ermera Municipality (Município)
    ('4517', 'Manatuto Municipality', '63'), -- Changed Manatuto District to Manatuto Municipality (Município)
    ('4518', 'Ainaro Municipality', '63'), -- Município
    ('4519', 'Manufahi Municipality', '63'), -- Município
    ('4520', 'Aileu Municipality', '63'), -- Município
    ('4521', 'Baucau Municipality', '63'), -- Município
    ('4522', 'Cova Lima Municipality', '63'), -- Município
    ('4523', 'Lautém Municipality', '63'), -- Lautém has 'é' (Município)
    ('4524', 'Dili Municipality', '63'), -- Município (Capital)
    ('4525', 'Bobonaro Municipality', '63'), -- Município
    ('4526', 'Peleliu', '168'), -- State (Palau)
    ('4527', 'Ngardmau', '168'), -- State
    ('4528', 'Airai', '168'), -- State
    ('4529', 'Hatohobei', '168'), -- State
    ('4530', 'Melekeok', '168'), -- State (Capital)
    ('4531', 'Ngatpang', '168'), -- State
    ('4532', 'Koror', '168'), -- State (Largest city)
    ('4533', 'Ngarchelong', '168'), -- State
    ('4534', 'Ngiwal', '168'), -- State
    ('4535', 'Sonsorol', '168'), -- State
    ('4536', 'Ngchesar', '168'), -- State
    ('4537', 'Ngaraard', '168'), -- State
    ('4538', 'Angaur', '168'), -- State
    ('4539', 'Kayangel', '168'), -- State
    ('4540', 'Aimeliik', '168'), -- State
    ('4541', 'Ngeremlengui', '168'), -- State
    ('4542', 'Břeclav District', '58'), -- Czech Republic (Okres)
    ('4543', 'Český Krumlov District', '58'), -- Fixed char (Okres)
    ('4544', 'Plzeň-City District', '58'), -- Plzeň has 'ň' (Okres)
    ('4545', 'Brno-Country District', '58'), -- Brno-venkov (Okres)
    ('4546', 'Příbram District', '58'), -- Příbram has 'í' (Okres)
    ('4547', 'Pardubice District', '58'), -- Okres
    ('4548', 'Nový Jičín District', '58'), -- Nový Jičín has 'ý', 'í' (Okres)
    ('4549', 'Prague 12 District', '58'), -- Changed Prague 12 to Prague 12 District (Městská část)
    ('4550', 'Náchod District', '58'), -- Okres
    ('4551', 'Prostějov District', '58'), -- Prostějov has 'ě' (Okres)
    ('4552', 'Zlín Region', '58'), -- Zlínský kraj (Kraj)
    ('4553', 'Chomutov District', '58'), -- Okres
    ('4554', 'Central Bohemian Region', '58'), -- Středočeský kraj (Kraj)
    ('4555', 'Prague 13 District', '58'), -- Changed Prague 13 to Prague 13 District (Městská část)
    ('4556', 'České Budějovice District', '58'), -- České Budějovice has 'Č', 'é', 'ě' (Okres)
    ('4557', 'Prague 5 District', '58'), -- Changed Prague 5 to Prague 5 District (Městská část)
    ('4558', 'Rakovník District', '58'), -- Okres
    ('4559', 'Frýdek-Místek District', '58'), -- Frýdek-Místek has 'ý', 'í' (Okres)
    ('4560', 'Písek District', '58'), -- Písek has 'í' (Okres)
    ('4561', 'Hodonín District', '58'), -- Okres
    ('4562', 'Prague 1 District', '58'), -- Changed Prague 1 to Prague 1 District (Městská část)
    ('4563', 'Zlín District', '58'), -- Okres
    ('4564', 'Plzeň-North District', '58'), -- Plzeň has 'ň' (Okres Plzeň-sever)
    ('4565', 'Tábor District', '58'), -- Tábor has 'á' (Okres)
    ('4566', 'Prague 9 District', '58'), -- Changed Prague 9 to Prague 9 District (Městská část)
    ('4567', 'Prague 16 District', '58'), -- Changed Prague 16 to Prague 16 District (Městská část - Radotín)
    ('4568', 'Brno-City District', '58'), -- Brno-město (Okres)
    ('4569', 'Prague 6 District', '58'), -- Changed Prague 6 to Prague 6 District (Městská část)
    ('4570', 'Prague 11 District', '58'), -- Changed Prague 11 to Prague 11 District (Městská část)
    ('4571', 'Svitavy District', '58'), -- Okres
    ('4572', 'Vsetín District', '58'), -- Okres
    ('4573', 'Cheb District', '58'), -- Okres
    ('4574', 'Olomouc District', '58'), -- Okres
    ('4575', 'Vysočina Region', '58'), -- Kraj Vysočina (Kraj)
    ('4576', 'Ústí nad Labem Region', '58'), -- Ústecký kraj (Fixed char - Kraj)
    (
        '4577',
        'Prague 20 District (Horní Počernice)',
        '58'
    ), -- Changed Horní Počernice to Prague 20 District (Horní Počernice), Horní Počernice has 'í', 'č' (Městská část)
    ('4578', 'Prachatice District', '58'), -- Okres
    ('4579', 'Trutnov District', '58'), -- Okres
    ('4580', 'Hradec Králové District', '58'), -- Hradec Králové has 'á', 'é' (Okres)
    ('4581', 'Karlovy Vary Region', '58'), -- Karlovarský kraj (Kraj)
    ('4582', 'Nymburk District', '58'), -- Okres
    ('4583', 'Rokycany District', '58'), -- Okres
    ('4584', 'Ostrava-City District', '58'), -- Ostrava-město (Okres)
    ('4585', 'Prague 14 District', '58'), -- Changed Prague 14 to Prague 14 District (Městská část)
    ('4586', 'Karviná District', '58'), -- Karviná has 'á' (Okres)
    ('4587', 'Prague 4 District', '58'), -- Changed Prague 4 to Prague 4 District (Městská část)
    ('4588', 'Pardubice Region', '58'), -- Pardubický kraj (Kraj)
    ('4589', 'Olomouc Region', '58'), -- Olomoucký kraj (Kraj)
    ('4590', 'Liberec District', '58'), -- Okres
    ('4591', 'Klatovy District', '58'), -- Okres
    ('4592', 'Uherské Hradiště District', '58'), -- Uherské Hradiště has 'é', 'š' (Okres)
    ('4593', 'Kroměříž District', '58'), -- Kroměříž has 'ě', 'ř', 'ž' (Okres)
    ('4594', 'Prague 8 District', '58'), -- Changed Prague 8 to Prague 8 District (Městská část)
    ('4595', 'Sokolov District', '58'), -- Okres
    ('4596', 'Semily District', '58'), -- Okres
    ('4597', 'Třebíč District', '58'), -- Třebíč has 'ř', 'í' (Okres)
    ('4598', 'Prague Capital City', '58'), -- Changed Prague to Prague Capital City (Hlavní město Praha - Kraj/Capital)
    ('4599', 'Ústí nad Labem District', '58'), -- Ústí has 'Ú', 'í' (Okres)
    ('4600', 'Moravian-Silesian Region', '58'), -- Moravskoslezský kraj (Kraj)
    ('4601', 'Liberec Region', '58'), -- Liberecký kraj (Kraj)
    ('4602', 'South Moravian Region', '58'), -- Jihomoravský kraj (Kraj)
    ('4603', 'Prague 10 District', '58'), -- Changed Prague 10 to Prague 10 District (Městská část)
    ('4604', 'Karlovy Vary District', '58'), -- Okres
    ('4605', 'Litoměřice District', '58'), -- Litoměřice has 'ř', 'ř' (Okres)
    ('4606', 'Prague-East District', '58'), -- Praha-východ (Okres)
    ('4607', 'Plzeň Region', '58'), -- Plzeňský kraj (Fixed char - Kraj)
    ('4608', 'Plzeň-South District', '58'), -- Plzeň has 'ň' (Okres Plzeň-jih)
    ('4609', 'Děčín District', '58'), -- Děčín has 'ě', 'í' (Okres)
    ('4610', 'Prague 7 District', '58'), -- Changed Prague 7 to Prague 7 District (Městská část)
    ('4611', 'Havlíčkův Brod District', '58'), -- Havlíčkův Brod has 'í', 'ů' (Okres)
    ('4612', 'Jablonec nad Nisou District', '58'), -- Okres
    ('4613', 'Jihlava District', '58'), -- Okres
    ('4614', 'Hradec Králové Region', '58'), -- Královéhradecký kraj (Fixed char - Kraj)
    ('4615', 'Blansko District', '58'), -- Okres
    ('4616', 'Prague 2 District', '58'), -- Changed Prague 2 to Prague 2 District (Městská část)
    ('4617', 'Louny District', '58'), -- Okres
    ('4618', 'Kolín District', '58'), -- Kolín has 'í' (Okres)
    ('4619', 'Prague-West District', '58'), -- Praha-západ (Okres)
    ('4620', 'Beroun District', '58'), -- Okres
    ('4621', 'Teplice District', '58'), -- Okres
    ('4622', 'Vyškov District', '58'), -- Vyškov has 'š' (Okres)
    ('4623', 'Opava District', '58'), -- Okres
    ('4624', 'Jindřichův Hradec District', '58'), -- Jindřichův Hradec has 'ř', 'ů', 'á' (Okres)
    ('4625', 'Jeseník District', '58'), -- Jeseník has 'í' (Okres)
    ('4626', 'Přerov District', '58'), -- Přerov has 'ř' (Okres)
    ('4627', 'Benešov District', '58'), -- Benešov has 'š' (Okres)
    ('4628', 'Strakonice District', '58'), -- Okres
    ('4629', 'Most District', '58'), -- Okres
    ('4630', 'Znojmo District', '58'), -- Okres
    ('4631', 'Kladno District', '58'), -- Okres
    (
        '4632',
        'Prague 21 District (Újezd nad Lesy)',
        '58'
    ), -- Changed Prague 21 to Prague 21 District (Újezd nad Lesy), Újezd has 'Ú' (Městská část)
    ('4633', 'Česká Lípa District', '58'), -- Česká Lípa has 'Č', 'á', 'í' (Okres)
    ('4634', 'Chrudim District', '58'), -- Okres
    ('4635', 'Prague 3 District', '58'), -- Changed Prague 3 to Prague 3 District (Městská část)
    ('4636', 'Rychnov nad Kněžnou District', '58'), -- Kněžnou has 'ž' (Okres)
    ('4637', 'Prague 15 District', '58'), -- Changed Prague 15 to Prague 15 District (Městská část)
    ('4638', 'Mělník District', '58'), -- Mělník has 'ě' (Okres)
    ('4639', 'South Bohemian Region', '58'), -- Jihočeský kraj (Fixed char - Kraj)
    ('4640', 'Jičín District', '58'), -- Jičín has 'í' (Okres)
    ('4641', 'Domažlice District', '58'), -- Domažlice has 'ž' (Okres)
    ('4642', 'Šumperk District', '58'), -- Šumperk has 'Š' (Okres)
    ('4643', 'Mladá Boleslav District', '58'), -- Mladá has 'á' (Okres)
    ('4644', 'Bruntál District', '58'), -- Okres
    ('4645', 'Pelhřimov District', '58'), -- Pelhřimov has 'ř' (Okres)
    ('4646', 'Tachov District', '58'), -- Okres
    ('4647', 'Ústí nad Orlicí District', '58'), -- Ústí nad Orlicí has 'Ú', 'í', 'í' (Okres)
    ('4648', 'Žďár nad Sázavou District', '58'), -- Žďár nad Sázavou has 'Ž', 'ď', 'á' (Okres)
    (
        '4649',
        'North East Community Development Council',
        '199'
    ), -- Singapore (CDC)
    (
        '4650',
        'South East Community Development Council',
        '199'
    ), -- CDC
    (
        '4651',
        'Central Singapore Community Development Council',
        '199'
    ), -- CDC
    (
        '4652',
        'South West Community Development Council',
        '199'
    ), -- CDC
    (
        '4653',
        'North West Community Development Council',
        '199'
    ), -- CDC
    ('4654', 'Ewa District', '153'), -- Nauru
    ('4655', 'Uaboe District', '153'),
    ('4656', 'Aiwo District', '153'),
    ('4657', 'Meneng District', '153'),
    ('4658', 'Anabar District', '153'),
    ('4659', 'Nibok District', '153'),
    ('4660', 'Baiti District', '153'),
    ('4661', 'Ijuw District', '153'),
    ('4662', 'Buada District', '153'),
    ('4663', 'Anibare District', '153'),
    ('4664', 'Yaren District', '153'), -- (De facto capital)
    ('4665', 'Boe District', '153'),
    ('4666', 'Denigomodu District', '153'),
    ('4667', 'Anetan District', '153'),
    ('4668', 'Zhytomyr Oblast', '230'), -- Ukraine (Oblast')
    ('4669', 'Vinnytsia Oblast', '230'), -- Oblast'
    ('4670', 'Zakarpattia Oblast', '230'), -- Oblast' (Transcarpathia)
    ('4671', 'Kyiv Oblast', '230'), -- Oblast'
    ('4672', 'Lviv Oblast', '230'), -- Oblast'
    ('4673', 'Luhansk Oblast', '230'), -- Oblast' (Partially occupied)
    ('4674', 'Ternopil Oblast', '230'), -- Oblast'
    ('4675', 'Dnipropetrovsk Oblast', '230'), -- Oblast'
    ('4676', 'Kyiv City', '230'), -- Changed Kiev to Kyiv City (City with special status - Capital)
    ('4677', 'Kirovohrad Oblast', '230'), -- Oblast'
    ('4678', 'Chernivtsi Oblast', '230'), -- Oblast'
    ('4679', 'Mykolaiv Oblast', '230'), -- Oblast'
    ('4680', 'Cherkasy Oblast', '230'), -- Oblast'
    ('4681', 'Khmelnytskyi Oblast', '230'), -- Changed Khmelnytsky to Khmelnytskyi Oblast (Oblast')
    ('4682', 'Ivano-Frankivsk Oblast', '230'), -- Oblast'
    ('4683', 'Rivne Oblast', '230'), -- Oblast'
    ('4684', 'Kherson Oblast', '230'), -- Oblast' (Partially occupied)
    ('4685', 'Sumy Oblast', '230'), -- Oblast'
    ('4686', 'Kharkiv Oblast', '230'), -- Oblast'
    ('4687', 'Zaporizhzhia Oblast', '230'), -- Changed Zaporizhzhya to Zaporizhzhia Oblast (Oblast' - Partially occupied)
    ('4688', 'Odesa Oblast', '230'), -- Changed Odessa to Odesa Oblast (Oblast')
    ('4689', 'Autonomous Republic of Crimea', '230'), -- Avtonomna Respublika Krym (De jure part of Ukraine, annexed by Russia 2014)
    ('4690', 'Volyn Oblast', '230'), -- Oblast'
    ('4691', 'Donetsk Oblast', '230'), -- Oblast' (Partially occupied)
    ('4692', 'Chernihiv Oblast', '230'), -- Oblast'
    ('4693', 'Gabrovo Province', '34'), -- Bulgaria (Oblast)
    ('4694', 'Smolyan Province', '34'), -- Oblast
    ('4695', 'Pernik Province', '34'), -- Oblast
    ('4696', 'Montana Province', '34'), -- Oblast
    ('4697', 'Vidin Province', '34'), -- Oblast
    ('4698', 'Razgrad Province', '34'), -- Oblast
    ('4699', 'Blagoevgrad Province', '34'), -- Oblast
    ('4700', 'Sliven Province', '34'), -- Oblast
    ('4701', 'Plovdiv Province', '34'), -- Oblast
    ('4702', 'Kardzhali Province', '34'), -- Oblast (Kărdzhali)
    ('4703', 'Kyustendil Province', '34'), -- Oblast
    ('4704', 'Haskovo Province', '34'), -- Oblast
    ('4705', 'Sofia City Province', '34'), -- Oblast Sofia-Grad (Capital)
    ('4706', 'Pleven Province', '34'), -- Oblast
    ('4707', 'Stara Zagora Province', '34'), -- Oblast
    ('4708', 'Silistra Province', '34'), -- Oblast
    ('4709', 'Veliko Tarnovo Province', '34'), -- Oblast
    ('4710', 'Lovech Province', '34'), -- Oblast
    ('4711', 'Vratsa Province', '34'), -- Oblast
    ('4712', 'Pazardzhik Province', '34'), -- Oblast
    ('4713', 'Ruse Province', '34'), -- Oblast
    ('4714', 'Targovishte Province', '34'), -- Oblast (Tărgovishte)
    ('4715', 'Burgas Province', '34'), -- Oblast
    ('4716', 'Yambol Province', '34'), -- Oblast
    ('4717', 'Varna Province', '34'), -- Oblast
    ('4718', 'Dobrich Province', '34'), -- Oblast
    ('4719', 'Sofia Province', '34'), -- Oblast Sofia (Region surrounding capital city)
    ('4720', 'Suceava County', '181'), -- Romania (Județ)
    ('4721', 'Hunedoara County', '181'), -- Județ
    ('4722', 'Argeș County', '181'), -- Changed Arges to Argeș County (Fixed char - Județ)
    ('4723', 'Bihor County', '181'), -- Județ
    ('4724', 'Alba County', '181'), -- Changed Alba to Alba County (Județ)
    ('4725', 'Ilfov County', '181'), -- Județ
    ('4726', 'Giurgiu County', '181'), -- Județ
    ('4727', 'Tulcea County', '181'), -- Județ
    ('4728', 'Teleorman County', '181'), -- Județ
    ('4729', 'Prahova County', '181'), -- Județ
    ('4730', 'Bucharest Municipality', '181'), -- Changed Bucharest to Bucharest Municipality (Municipiu - Capital)
    ('4731', 'Neamț County', '181'), -- Neamț has 'ț' (Județ)
    ('4732', 'Călărași County', '181'), -- Călărași has 'ă', 'ș' (Județ)
    ('4733', 'Bistrița-Năsăud County', '181'), -- Bistrița has 'ț', Năsăud has 'ă' (Județ)
    ('4734', 'Cluj County', '181'), -- Județ
    ('4735', 'Iași County', '181'), -- Iași has 'ș' (Județ)
    ('4736', 'Brăila County', '181'), -- Changed Braila to Brăila County (Fixed char - Județ)
    ('4737', 'Constanța County', '181'), -- Constanța has 'ț' (Județ)
    ('4738', 'Olt County', '181'), -- Județ
    ('4739', 'Arad County', '181'), -- Județ
    ('4740', 'Botoșani County', '181'), -- Botoșani has 'ș' (Județ)
    ('4741', 'Sălaj County', '181'), -- Sălaj has 'ă' (Județ)
    ('4742', 'Dolj County', '181'), -- Județ
    ('4743', 'Ialomița County', '181'), -- Ialomița has 'ț' (Județ)
    ('4744', 'Bacău County', '181'), -- Bacău has 'ă' (Județ)
    ('4745', 'Dâmbovița County', '181'), -- Dâmbovița has 'â', 'ț' (Județ)
    ('4746', 'Satu Mare County', '181'), -- Județ
    ('4747', 'Galați County', '181'), -- Galați has 'ț' (Județ)
    ('4748', 'Timiș County', '181'), -- Timiș has 'ș' (Județ)
    ('4749', 'Harghita County', '181'), -- Județ
    ('4750', 'Gorj County', '181'), -- Județ
    ('4751', 'Mehedinți County', '181'), -- Mehedinți has 'ț' (Județ)
    ('4752', 'Vaslui County', '181'), -- Județ
    ('4753', 'Caraș-Severin County', '181'), -- Caraș has 'ș', Severin has 'ș' (Județ)
    ('4754', 'Covasna County', '181'), -- Județ
    ('4755', 'Sibiu County', '181'), -- Județ
    ('4756', 'Buzău County', '181'), -- Buzău has 'ă' (Județ)
    ('4757', 'Vâlcea County', '181'), -- Vâlcea has 'â' (Județ)
    ('4758', 'Vrancea County', '181'), -- Județ
    ('4759', 'Brașov County', '181'), -- Brașov has 'ș' (Județ)
    ('4760', 'Mureș County', '181'), -- Mureș has 'ș' (Județ)
    ('4761', 'Aiga-i-le-Tai District', '191'), -- Samoa (Itūmālō)
    ('4762', 'Satupa''itea District', '191'), -- Fixed escaping (Itūmālō)
    ('4763', 'A''ana District', '191'), -- Fixed escaping (Itūmālō)
    ('4764', 'Fa''asaleleaga District', '191'), -- Fixed escaping (Itūmālō)
    ('4765', 'Atua District', '191'), -- Itūmālō
    ('4766', 'Vaisigano District', '191'), -- Itūmālō
    ('4767', 'Palauli District', '191'), -- Itūmālō
    ('4768', 'Va''a-o-Fonoti District', '191'), -- Fixed escaping (Itūmālō)
    ('4769', 'Gaga''emauga District', '191'), -- Fixed escaping (Itūmālō)
    ('4770', 'Tuamasaga District', '191'), -- Itūmālō (Capital area)
    ('4771', 'Gaga''ifomauga District', '191'), -- Fixed escaping (Itūmālō)
    ('4772', 'Torba Province', '237'), -- Vanuatu
    ('4773', 'Penama Province', '237'),
    ('4774', 'Shefa Province', '237'), -- (Capital province)
    ('4775', 'Malampa Province', '237'),
    ('4776', 'Sanma Province', '237'),
    ('4777', 'Tafea Province', '237'),
    ('4778', 'Honiara Capital Territory', '202'), -- Changed Honiara to Honiara Capital Territory (Solomon Islands)
    ('4779', 'Temotu Province', '202'),
    ('4780', 'Isabel Province', '202'),
    ('4781', 'Choiseul Province', '202'),
    ('4782', 'Makira-Ulawa Province', '202'),
    ('4783', 'Malaita Province', '202'),
    ('4784', 'Central Province', '202'),
    ('4785', 'Guadalcanal Province', '202'),
    ('4786', 'Western Province', '202'),
    ('4787', 'Rennell and Bellona Province', '202'),
    ('4788', 'Burgundy (historical)', '75'), -- France (Region - Merged into Bourgogne-Franche-Comté 2016)
    ('4789', 'Auvergne (historical)', '75'), -- Region - Merged into Auvergne-Rhône-Alpes 2016
    ('4790', 'Picardy (historical)', '75'), -- Region - Merged into Hauts-de-France 2016
    ('4791', 'Champagne-Ardenne (historical)', '75'), -- Region - Merged into Grand Est 2016
    ('4792', 'Limousin (historical)', '75'), -- Region - Merged into Nouvelle-Aquitaine 2016
    ('4793', 'Nord-Pas-de-Calais (historical)', '75'), -- Region - Merged into Hauts-de-France 2016
    ('4794', 'Saint Barthélemy', '75'), -- Overseas Collectivity (Saint-Barthélemy)
    ('4795', 'Nouvelle-Aquitaine', '75'), -- Region (New Aquitaine)
    ('4796', 'Île-de-France', '75'), -- Fixed char (Region - Capital Region)
    ('4797', 'Mayotte', '75'), -- Overseas Department/Region
    ('4798', 'Auvergne-Rhône-Alpes', '75'), -- Region
    ('4799', 'Occitania', '75'), -- Occitanie (Region)
    ('4800', 'Alo', '75'), -- Chiefdom (Wallis and Futuna)
    ('4801', 'Lorraine (historical)', '75'), -- Region - Merged into Grand Est 2016
    ('4802', 'Pays de la Loire', '75'), -- Region
    ('4803', 'Languedoc-Roussillon (historical)', '75'), -- Region - Merged into Occitania 2016
    ('4804', 'Normandy', '75'), -- Normandie (Region)
    ('4805', 'Franche-Comté (historical)', '75'), -- Franche-Comté has 'é' (Region - Merged into Bourgogne-Franche-Comté 2016)
    ('4806', 'Corsica', '75'), -- Corse (Territorial Collectivity)
    ('4807', 'Brittany', '75'), -- Bretagne (Region)
    ('4808', 'Aquitaine (historical)', '75'), -- Region - Merged into Nouvelle-Aquitaine 2016
    ('4809', 'Saint Martin', '75'), -- Overseas Collectivity (Saint-Martin)
    ('4810', 'Wallis and Futuna', '75'), -- Overseas Collectivity
    ('4811', 'Alsace (historical)', '75'), -- Region - Merged into Grand Est 2016, partially reinstated as European Collectivity of Alsace 2021
    ('4812', 'Provence-Alpes-Côte d''Azur', '75'), -- Fixed escaping (Region)
    ('4813', 'Rhône-Alpes (historical)', '75'), -- Rhône-Alpes has 'ô' (Region - Merged into Auvergne-Rhône-Alpes 2016)
    ('4814', 'Lower Normandy (historical)', '75'), -- Basse-Normandie (Region - Merged into Normandy 2016)
    ('4815', 'Poitou-Charentes (historical)', '75'), -- Region - Merged into Nouvelle-Aquitaine 2016
    ('4816', 'Paris', '75'), -- Department/City (Part of Île-de-France Region)
    ('4817', 'Uvea', '75'), -- Chiefdom (Wallis and Futuna - Wallis Island)
    ('4818', 'Centre-Val de Loire', '75'), -- Region
    ('4819', 'Sigave', '75'), -- Chiefdom (Wallis and Futuna)
    ('4820', 'Grand Est', '75'), -- Region
    ('4821', 'Saint Pierre and Miquelon', '75'), -- Overseas Collectivity (Saint-Pierre-et-Miquelon)
    ('4822', 'French Guiana', '75'), -- Guyane (Overseas Department/Region)
    ('4823', 'Réunion', '75'), -- Réunion has 'é' (Overseas Department/Region)
    ('4824', 'French Polynesia', '75'), -- Polynésie française (Overseas Collectivity)
    ('4825', 'Bourgogne-Franche-Comté', '75'), -- Fixed char (Region)
    ('4826', 'Upper Normandy (historical)', '75'), -- Haute-Normandie (Region - Merged into Normandy 2016)
    ('4827', 'Martinique', '75'), -- Overseas Department/Region
    ('4828', 'Hauts-de-France', '75'), -- Region
    ('4829', 'Guadeloupe', '75'), -- Overseas Department/Region
    ('4830', 'West New Britain Province', '171'), -- Papua New Guinea
    (
        '4831',
        'Autonomous Region of Bougainville',
        '171'
    ), -- Changed Bougainville to Autonomous Region of Bougainville
    ('4832', 'Jiwaka Province', '171'),
    ('4833', 'Hela Province', '171'), -- Changed Hela to Hela Province
    ('4834', 'East New Britain Province', '171'), -- Changed East New Britain to East New Britain Province
    ('4835', 'Morobe Province', '171'),
    ('4836', 'Sandaun Province', '171'), -- (West Sepik Province)
    ('4837', 'National Capital District', '171'), -- Changed Port Moresby to National Capital District
    ('4838', 'Oro Province', '171'), -- (Northern Province)
    ('4839', 'Gulf Province', '171'), -- Changed Gulf to Gulf Province
    ('4840', 'Western Highlands Province', '171'),
    ('4841', 'New Ireland Province', '171'),
    ('4842', 'Manus Province', '171'),
    ('4843', 'Madang Province', '171'),
    ('4844', 'Southern Highlands Province', '171'),
    ('4845', 'Eastern Highlands Province', '171'),
    ('4846', 'Chimbu Province', '171'), -- (Simbu Province)
    ('4847', 'Central Province', '171'),
    ('4848', 'Enga Province', '171'),
    ('4849', 'Milne Bay Province', '171'),
    ('4850', 'Western Province', '171'), -- (Fly River Province)
    ('4851', 'Ohio', '233'), -- State (USA)
    ('4852', 'Ladakh', '101'), -- Union Territory (India - Status changed 2019)
    ('4853', 'West Bengal', '101'), -- State
    ('4854', 'Sinop Province', '225'), -- Turkey (İl)
    ('4855', 'Capital District', '239'), -- Venezuela (Distrito Capital - Caracas)
    ('4856', 'Apure State', '239'), -- Changed Apure to Apure State (Estado)
    ('4857', 'Jalisco', '142'), -- State (Mexico)
    ('4858', 'Roraima', '31'), -- State (Brazil)
    ('4859', 'Guarda District', '177'), -- Portugal
    ('4860', 'Devonshire Parish', '25'), -- Bermuda
    ('4861', 'Hamilton Parish', '25'),
    ('4862', 'Hamilton City', '25'), -- Changed Hamilton Municipality to Hamilton City (Municipality - Capital)
    ('4863', 'Paget Parish', '25'),
    ('4864', 'Pembroke Parish', '25'),
    ('4865', 'Saint George Town', '25'), -- Changed Saint George's Municipality to Saint George Town (Municipality)
    ('4866', 'Saint George''s Parish', '25'), -- Fixed escaping
    ('4867', 'Sandys Parish', '25'),
    ('4868', 'Smith''s Parish', '25'), -- Changed Smith's Parish, to Smith's Parish (Fixed escaping and comma)
    ('4869', 'Southampton Parish', '25'),
    ('4870', 'Warwick Parish', '25'),
    ('4871', 'Huila Department', '48'), -- Colombia (Departamento)
    -- Missing IDs 4872, 4873
    ('4874', 'Ferizaj District', '248'), -- Changed Uroševac District (Ferizaj) to Ferizaj District (Kosovo - Rajon)
    -- Missing ID 4875
    ('4876', 'Gjakova District', '248'), -- Changed Đakovica District (Gjakove) to Gjakova District (Rajon)
    ('4877', 'Gjilan District', '248'), -- Rajon
    ('4878', 'Mitrovica District', '248'), -- Changed Kosovska Mitrovica District to Mitrovica District (Rajon)
    ('4879', 'Pristina District', '248'), -- Prishtina (Rajon - Capital)
    ('4880', 'Autonomous City of Buenos Aires', '11'), -- Ciudad Autónoma de Buenos Aires (Argentina - Capital Federal)
    ('4881', 'New Providence', '17'), -- Island (Bahamas - Contains Capital Nassau, administered directly)
    ('4882', 'Shumen Province', '34'), -- Changed Shumen to Shumen Province (Bulgaria - Oblast)
    ('4883', 'Rivers State', '161');

-- Nigeria