#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE TABLE IF NOT EXISTS users
    (
        id integer NOT NULL GENERATED BY DEFAULT AS IDENTITY,
        login text NOT NULL,
        salt text NOT NULL DEFAULT 'SERVICE',
        config jsonb NOT NULL,
        name text NOT NULL DEFAULT 'SERVICE',
        enabled boolean NOT NULL DEFAULT true,
        CONSTRAINT users_pkey PRIMARY KEY (id),
        CONSTRAINT users_login_key UNIQUE (login)
    );

    CREATE TABLE IF NOT EXISTS refresh_sessions
    (
        user_id integer NOT NULL,
        refresh_token uuid NOT NULL,
        fingerprint text NOT NULL,
        expires_in timestamp with time zone NOT NULL,
        CONSTRAINT refresh_sessions_pkey PRIMARY KEY (refresh_token),
        CONSTRAINT refresh_sessions_user_id_fkey FOREIGN KEY (user_id)
            REFERENCES users (id) MATCH SIMPLE
            ON UPDATE NO ACTION
            ON DELETE NO ACTION
            NOT VALID
    );

    CREATE TABLE IF NOT EXISTS hashes
    (
        hash text NOT NULL
    );

    INSERT INTO users (login, config)
        VALUES
            ('admin', '{
                "smpo_zpm": {
                    "params": {
                     "ncBook": {
                       "signNc": {
                         "showActHistory": false
                       },
                       "showNormData": true,
                       "showAllNcBook": false
                     },
                     "mailSendingPeriod": {
                       "signNc": {
                         "signNc": 10,
                         "refuseNc": 10,
                         "firstLvlNotifyNc": 10,
                         "fullSignedNotifyNc": 10
                       }
                     }
                    },
                    "reports": [
                     1,
                     6
                    ],
                    "machines": [1,2,3,4,5,6,7,8,9,10,16,17],
                    "roleName": "administrator"
                },
                "passport": {
                    "roles": [
                        "ROLE_ADMIN"
                    ],
                    "credentials_exp": 1672513199001
                }
            }'),
            ('zpm_operator', '{
                "smpo_zpm": {
                    "params": {
                        "ncBook": {
                            "signNc": {
                                "showActHistory":true
                            },
                                "showNormData":false,
                                "showAllNcBook":true
                        }
                    },
                    "reports":[10],
                    "machines": [1,2,3,4,5,6,7,8,9,10,16,17],
                    "roleName":"operator"
                },
                "passport": {
                    "credentials_exp": 1672513199001
                }
            }'),
            ('zpm_director', '{
                "smpo_zpm": {
                    "params": {
                        "ncBook": {
                            "signNc": {
                                "showActHistory": false
                            },
                            "showNormData": true,
                            "showAllNcBook": false
                        }
                    },
                    "reports": [
                        1,
                        3,
                        5,
                        6,
                        7,
                        8,
                        9,
                        10,
                        11,
                        12,
                        14,
                        13,
                        15,
                        17,
                        18
                    ],
                    "machines": [1,2,3,4,5,6,7,8,9,10,16,17],
                    "roleName": "director"
                },
                "planner": {
                    "areas": [1,4,5],
                    "roles": ["ROLE_TRACK"],
                    "privileges": ["ORDER_DATE","PLAN_AREA"]
                },
                "passport": {
                    "credentials_exp": 1672513199001
                }
            }'),
            ('zpm_foreman', '{
                "smpo_zpm": {
                    "params": {
                        "ncBook": {
                            "signNc": {
                                "showActHistory": false
                            },
                            "showNormData": true,
                            "showAllNcBook": false
                        },
                        "mailSendingPeriod": {
                            "signNc": {
                            "signNc": 10
                            }
                        }
                    },
                    "reports": [
                        6,
                        1,
                        3,
                        7,
                        8,
                        5,
                        13,
                        14,
                        12,
                        9,
                        10,
                        11,
                        15,
                        17,
                        18
                    ],
                    "machines": [1,2,3,4,5,6,7,8,9,10,16,17],
                    "roleName": "foreman"
                },
                "passport": {
                    "credentials_exp": 1672513199001
                }
            }'),
            ('zpm_softwareengineer', '{
                "smpo_zpm": {
                    "params": {
                        "ncBook": {
                            "signNc": {
                                "showActHistory": false
                            },
                            "showNormData": true,
                            "showAllNcBook": true
                        },
                        "mailSendingPeriod": {
                            "signNc": {
                                "signNc": 10,
                                "refuseNc": 10
                            }
                        }
                    },
                    "reports": [
                        1,
                        3,
                        7,
                        8,
                        5,
                        10,
                        11,
                        6,
                        9,
                        4,
                        13,
                        12
                    ],
                    "machines": [1,2,3,4,5,6,7,8,9,10,16,17],
                    "roleName": "softwareEngineer"
                },
                "passport": {
                    "credentials_exp": 1672513199001
                }
            }'),
            ('sgm_mechanic', '{
                "smpo_zpm": {
                    "params": {
                        "ncBook": {
                            "signNc": {
                                "showActHistory": false
                            },
                            "showNormData": true,
                            "showAllNcBook": false
                        }
                    },
                    "reports": [
                        1,
                        5,
                        6,
                        3,
                        8,
                        14,
                        15
                    ],
                    "machines": [1,2,3,4,5,6,7,8,9,10,16,17],
                    "roleName": "mechanic"
                },
                "passport": {
                    "credentials_exp": 1672513199001
                }
            }'),
            ('zpm_deputyDirector', '{
                "smpo_zpm": {
                    "params": {
                        "ncBook": {
                            "signNc": {
                                "showActHistory": false
                            },
                            "showNormData": true,
                            "showAllNcBook": false
                        }
                    },
                    "reports": [
                        1,
                        3,
                        5,
                        6,
                        7,
                        8,
                        9,
                        10,
                        11,
                        12
                    ],
                    "machines": [1,2,3,4,5,6,7,8,9,10,16,17],
                    "roleName": "deputyDirector"
                },
                "passport": {
                    "credentials_exp": 1672513199001
                }
            }'),
            ('zpm_chiefEngineer', '{
                "smpo_zpm": {
                    "params": {
                        "ncBook": {
                            "signNc": {
                                "showActHistory": true
                            },
                            "showNormData": true,
                            "showAllNcBook": false
                        },
                        "mailSendingPeriod": {
                            "signNc": {
                                "signNc": 10
                            }
                        }
                    },
                    "reports": [
                        1,
                        3,
                        5,
                        6,
                        7,
                        8,
                        9,
                        10,
                        11,
                        12
                    ],
                    "machines": [1,2,3,4,5,6,7,8,9,10,16,17],
                    "roleName": "chiefEngineer"
                },
                "passport": {
                    "credentials_exp": 1672513199001
                }
            }'),
            ('zpm_chiefTechDpt', '{
                "smpo_zpm": {
                    "params": {
                        "ncBook": {
                            "signNc": {
                                "showActHistory": false
                            },
                            "showNormData": true,
                            "showAllNcBook": false
                        }
                    },
                    "reports": [
                        1,
                        3,
                        7,
                        8,
                        5,
                        6
                    ],
                    "machines": [1,2,3,4,5,6,7,8,9,10,16,17],
                    "roleName": "chiefTechDpt"
                },
                "passport": {
                    "credentials_exp": 1672513199001
                }
            }'),
            ('zpm_chiefTechOffice', '{
                "smpo_zpm": {
                    "params": {
                        "ncBook": {
                            "signNc": {
                                "showActHistory": false
                            },
                            "showNormData": true,
                            "showAllNcBook": false
                        },
                        "mailSendingPeriod": {
                            "signNc": {
                                "signNc": 10
                            }
                        }
                    },
                    "reports": [
                        3,
                        7,
                        8
                    ],
                    "machines": [1,2,3,4,5,6,7,8,9,10,16,17],
                    "roleName": "chiefTechOffice"
                },
                "passport": {
                    "credentials_exp": 1672513199001
                }
            }'),
            ('zpm_techEngineer', '{
                "smpo_zpm": {
                    "params": {
                        "ncBook": {
                            "signNc": {
                                "showActHistory": false
                            },
                            "showNormData": true,
                            "showAllNcBook": false
                        },
                        "mailSendingPeriod": {
                            "signNc": {
                                "firstLvlNotifyNc": 10
                            }
                        }
                    },
                    "reports": [
                        7,
                        8
                    ],
                    "machines": [1,2,3,4,5,6,7,8,9,10,16,17],
                    "roleName": "techEngineer"
                },
                "passport": {
                    "credentials_exp": 1672513199001
                }
            }'),
            ('zpm_qualityEngineer', '{
                "smpo_zpm": {
                    "params": {
                        "ncBook": {
                            "signNc": {
                                "showActHistory": false
                            },
                            "showNormData": true,
                            "showAllNcBook": false
                        }
                    },
                    "reports": [
                        9,
                        10,
                        11,
                        12
                    ],
                    "machines": [1,2,3,4,5,6,7,8,9,10,16,17],
                    "roleName": "qualityEngineer"
                },
                "passport": {
                    "credentials_exp": 1672513199001
                }
            }'),
            ('zpm_normEngineer', '{
                "smpo_zpm": {
                    "params": {
                        "ncBook": {
                            "signNc": {
                                "showActHistory": true
                            },
                            "showNormData": true,
                            "showAllNcBook": true
                        },
                        "mailSendingPeriod": {
                            "signNc": {
                                "signNc": 10,
                                "fullSignedNotifyNc": 10
                            }
                        }
                    },
                    "reports": [],
                    "machines": [1,2,3,4,5,6,7,8,9,10,16,17],
                    "roleName": "normEngineer"
                },
                "passport": {
                    "credentials_exp": 1672513199001
                }
            }'),
            ('pnppk_user', '{
                "smpo_zpm": {
                    "params": {
                        "ncBook": {
                            "signNc": {
                                "showActHistory": false
                            },
                            "showNormData": true,
                            "showAllNcBook": false
                        }
                    },
                    "reports": [
                        3,
                        13
                    ],
                    "machines": [1,2,3,4,5,6,7,8,9,10,16,17],
                    "roleName": "universal"
                },
                "passport": {
                    "credentials_exp": 1672513199001
                }
            }'),
            ('sgm_chiefMechanic', '{
                "smpo_zpm": {
                    "params": {
                        "ncBook": {
                            "signNc": {
                                "showActHistory": false
                            },
                            "showNormData": true,
                            "showAllNcBook": false
                        }
                    },
                    "reports": [
                        8,
                        1,
                        5,
                        3,
                        15,
                        6,
                        14
                    ],
                    "machines": [1,2,3,4,5,6,7,8,9,10,16,17],
                    "roleName": "chiefMechanic"
                },
                "passport": {
                    "credentials_exp": 1672513199001
                }
            }'),
            ('direction_techDirector', '{
                "smpo_zpm": {
                    "params": {
                        "ncBook": {
                            "signNc": {
                                "showActHistory": false
                            },
                            "showNormData": true,
                            "showAllNcBook": false
                        }
                    },
                    "reports": [
                        12,
                        9,
                        6,
                        14,
                        3,
                        10
                    ],
                    "machines": [1,2,3,4,5,6,7,8,9,10,16,17],
                    "roleName": "techDirector"
                },
                "passport": {
                    "credentials_exp": 1672513199001
                }
            }'),
            ('SMPO', '{
                "smpo_zpm": {},
                "passport": {
                    "credentials_exp": 1672513199001
                }
            }'),
            ('progs', '{
                "smpo_zpm": {
                    "params": {
                        "ncBook": {
                            "signNc": {
                                "showActHistory": false
                            },
                            "showNormData": true,
                            "showAllNcBook": true
                        },
                        "mailSendingPeriod": {
                            "signNc": {
                                "signNc": 10,
                                "refuseNc": 10
                            }
                        }
                    },
                    "reports": [
                        1,
                        3,
                        7,
                        8,
                        5,
                        10,
                        11,
                        6,
                        9,
                        4,
                        13,
                        12
                    ],
                    "machines": [1,2,3,4,5,6,7,8,9,10,16,17],
                    "roleName": "softwareEngineer"
                },
                "passport": {
                    "credentials_exp": 1672513199001
                }
            }');
    UPDATE users SET name = 'NAME' WHERE login = 'progs';

    INSERT INTO hashes VALUES ('dummy');
EOSQL
