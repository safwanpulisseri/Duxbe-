export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  auth: {
    Tables: {
      audit_log_entries: {
        Row: {
          created_at: string | null
          id: string
          instance_id: string | null
          ip_address: string
          payload: Json | null
        }
        Insert: {
          created_at?: string | null
          id: string
          instance_id?: string | null
          ip_address?: string
          payload?: Json | null
        }
        Update: {
          created_at?: string | null
          id?: string
          instance_id?: string | null
          ip_address?: string
          payload?: Json | null
        }
        Relationships: []
      }
      flow_state: {
        Row: {
          auth_code: string
          auth_code_issued_at: string | null
          authentication_method: string
          code_challenge: string
          code_challenge_method: Database["auth"]["Enums"]["code_challenge_method"]
          created_at: string | null
          id: string
          provider_access_token: string | null
          provider_refresh_token: string | null
          provider_type: string
          updated_at: string | null
          user_id: string | null
        }
        Insert: {
          auth_code: string
          auth_code_issued_at?: string | null
          authentication_method: string
          code_challenge: string
          code_challenge_method: Database["auth"]["Enums"]["code_challenge_method"]
          created_at?: string | null
          id: string
          provider_access_token?: string | null
          provider_refresh_token?: string | null
          provider_type: string
          updated_at?: string | null
          user_id?: string | null
        }
        Update: {
          auth_code?: string
          auth_code_issued_at?: string | null
          authentication_method?: string
          code_challenge?: string
          code_challenge_method?: Database["auth"]["Enums"]["code_challenge_method"]
          created_at?: string | null
          id?: string
          provider_access_token?: string | null
          provider_refresh_token?: string | null
          provider_type?: string
          updated_at?: string | null
          user_id?: string | null
        }
        Relationships: []
      }
      identities: {
        Row: {
          created_at: string | null
          email: string | null
          id: string
          identity_data: Json
          last_sign_in_at: string | null
          provider: string
          provider_id: string
          updated_at: string | null
          user_id: string
        }
        Insert: {
          created_at?: string | null
          email?: string | null
          id?: string
          identity_data: Json
          last_sign_in_at?: string | null
          provider: string
          provider_id: string
          updated_at?: string | null
          user_id: string
        }
        Update: {
          created_at?: string | null
          email?: string | null
          id?: string
          identity_data?: Json
          last_sign_in_at?: string | null
          provider?: string
          provider_id?: string
          updated_at?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "identities_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      instances: {
        Row: {
          created_at: string | null
          id: string
          raw_base_config: string | null
          updated_at: string | null
          uuid: string | null
        }
        Insert: {
          created_at?: string | null
          id: string
          raw_base_config?: string | null
          updated_at?: string | null
          uuid?: string | null
        }
        Update: {
          created_at?: string | null
          id?: string
          raw_base_config?: string | null
          updated_at?: string | null
          uuid?: string | null
        }
        Relationships: []
      }
      mfa_amr_claims: {
        Row: {
          authentication_method: string
          created_at: string
          id: string
          session_id: string
          updated_at: string
        }
        Insert: {
          authentication_method: string
          created_at: string
          id: string
          session_id: string
          updated_at: string
        }
        Update: {
          authentication_method?: string
          created_at?: string
          id?: string
          session_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "mfa_amr_claims_session_id_fkey"
            columns: ["session_id"]
            isOneToOne: false
            referencedRelation: "sessions"
            referencedColumns: ["id"]
          },
        ]
      }
      mfa_challenges: {
        Row: {
          created_at: string
          factor_id: string
          id: string
          ip_address: unknown
          otp_code: string | null
          verified_at: string | null
          web_authn_session_data: Json | null
        }
        Insert: {
          created_at: string
          factor_id: string
          id: string
          ip_address: unknown
          otp_code?: string | null
          verified_at?: string | null
          web_authn_session_data?: Json | null
        }
        Update: {
          created_at?: string
          factor_id?: string
          id?: string
          ip_address?: unknown
          otp_code?: string | null
          verified_at?: string | null
          web_authn_session_data?: Json | null
        }
        Relationships: [
          {
            foreignKeyName: "mfa_challenges_auth_factor_id_fkey"
            columns: ["factor_id"]
            isOneToOne: false
            referencedRelation: "mfa_factors"
            referencedColumns: ["id"]
          },
        ]
      }
      mfa_factors: {
        Row: {
          created_at: string
          factor_type: Database["auth"]["Enums"]["factor_type"]
          friendly_name: string | null
          id: string
          last_challenged_at: string | null
          phone: string | null
          secret: string | null
          status: Database["auth"]["Enums"]["factor_status"]
          updated_at: string
          user_id: string
          web_authn_aaguid: string | null
          web_authn_credential: Json | null
        }
        Insert: {
          created_at: string
          factor_type: Database["auth"]["Enums"]["factor_type"]
          friendly_name?: string | null
          id: string
          last_challenged_at?: string | null
          phone?: string | null
          secret?: string | null
          status: Database["auth"]["Enums"]["factor_status"]
          updated_at: string
          user_id: string
          web_authn_aaguid?: string | null
          web_authn_credential?: Json | null
        }
        Update: {
          created_at?: string
          factor_type?: Database["auth"]["Enums"]["factor_type"]
          friendly_name?: string | null
          id?: string
          last_challenged_at?: string | null
          phone?: string | null
          secret?: string | null
          status?: Database["auth"]["Enums"]["factor_status"]
          updated_at?: string
          user_id?: string
          web_authn_aaguid?: string | null
          web_authn_credential?: Json | null
        }
        Relationships: [
          {
            foreignKeyName: "mfa_factors_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      one_time_tokens: {
        Row: {
          created_at: string
          id: string
          relates_to: string
          token_hash: string
          token_type: Database["auth"]["Enums"]["one_time_token_type"]
          updated_at: string
          user_id: string
        }
        Insert: {
          created_at?: string
          id: string
          relates_to: string
          token_hash: string
          token_type: Database["auth"]["Enums"]["one_time_token_type"]
          updated_at?: string
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          relates_to?: string
          token_hash?: string
          token_type?: Database["auth"]["Enums"]["one_time_token_type"]
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "one_time_tokens_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      refresh_tokens: {
        Row: {
          created_at: string | null
          id: number
          instance_id: string | null
          parent: string | null
          revoked: boolean | null
          session_id: string | null
          token: string | null
          updated_at: string | null
          user_id: string | null
        }
        Insert: {
          created_at?: string | null
          id?: number
          instance_id?: string | null
          parent?: string | null
          revoked?: boolean | null
          session_id?: string | null
          token?: string | null
          updated_at?: string | null
          user_id?: string | null
        }
        Update: {
          created_at?: string | null
          id?: number
          instance_id?: string | null
          parent?: string | null
          revoked?: boolean | null
          session_id?: string | null
          token?: string | null
          updated_at?: string | null
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "refresh_tokens_session_id_fkey"
            columns: ["session_id"]
            isOneToOne: false
            referencedRelation: "sessions"
            referencedColumns: ["id"]
          },
        ]
      }
      saml_providers: {
        Row: {
          attribute_mapping: Json | null
          created_at: string | null
          entity_id: string
          id: string
          metadata_url: string | null
          metadata_xml: string
          name_id_format: string | null
          sso_provider_id: string
          updated_at: string | null
        }
        Insert: {
          attribute_mapping?: Json | null
          created_at?: string | null
          entity_id: string
          id: string
          metadata_url?: string | null
          metadata_xml: string
          name_id_format?: string | null
          sso_provider_id: string
          updated_at?: string | null
        }
        Update: {
          attribute_mapping?: Json | null
          created_at?: string | null
          entity_id?: string
          id?: string
          metadata_url?: string | null
          metadata_xml?: string
          name_id_format?: string | null
          sso_provider_id?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "saml_providers_sso_provider_id_fkey"
            columns: ["sso_provider_id"]
            isOneToOne: false
            referencedRelation: "sso_providers"
            referencedColumns: ["id"]
          },
        ]
      }
      saml_relay_states: {
        Row: {
          created_at: string | null
          flow_state_id: string | null
          for_email: string | null
          id: string
          redirect_to: string | null
          request_id: string
          sso_provider_id: string
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          flow_state_id?: string | null
          for_email?: string | null
          id: string
          redirect_to?: string | null
          request_id: string
          sso_provider_id: string
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          flow_state_id?: string | null
          for_email?: string | null
          id?: string
          redirect_to?: string | null
          request_id?: string
          sso_provider_id?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "saml_relay_states_flow_state_id_fkey"
            columns: ["flow_state_id"]
            isOneToOne: false
            referencedRelation: "flow_state"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "saml_relay_states_sso_provider_id_fkey"
            columns: ["sso_provider_id"]
            isOneToOne: false
            referencedRelation: "sso_providers"
            referencedColumns: ["id"]
          },
        ]
      }
      schema_migrations: {
        Row: {
          version: string
        }
        Insert: {
          version: string
        }
        Update: {
          version?: string
        }
        Relationships: []
      }
      sessions: {
        Row: {
          aal: Database["auth"]["Enums"]["aal_level"] | null
          created_at: string | null
          factor_id: string | null
          id: string
          ip: unknown | null
          not_after: string | null
          refreshed_at: string | null
          tag: string | null
          updated_at: string | null
          user_agent: string | null
          user_id: string
        }
        Insert: {
          aal?: Database["auth"]["Enums"]["aal_level"] | null
          created_at?: string | null
          factor_id?: string | null
          id: string
          ip?: unknown | null
          not_after?: string | null
          refreshed_at?: string | null
          tag?: string | null
          updated_at?: string | null
          user_agent?: string | null
          user_id: string
        }
        Update: {
          aal?: Database["auth"]["Enums"]["aal_level"] | null
          created_at?: string | null
          factor_id?: string | null
          id?: string
          ip?: unknown | null
          not_after?: string | null
          refreshed_at?: string | null
          tag?: string | null
          updated_at?: string | null
          user_agent?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "sessions_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      sso_domains: {
        Row: {
          created_at: string | null
          domain: string
          id: string
          sso_provider_id: string
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          domain: string
          id: string
          sso_provider_id: string
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          domain?: string
          id?: string
          sso_provider_id?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "sso_domains_sso_provider_id_fkey"
            columns: ["sso_provider_id"]
            isOneToOne: false
            referencedRelation: "sso_providers"
            referencedColumns: ["id"]
          },
        ]
      }
      sso_providers: {
        Row: {
          created_at: string | null
          id: string
          resource_id: string | null
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          id: string
          resource_id?: string | null
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          id?: string
          resource_id?: string | null
          updated_at?: string | null
        }
        Relationships: []
      }
      users: {
        Row: {
          aud: string | null
          banned_until: string | null
          confirmation_sent_at: string | null
          confirmation_token: string | null
          confirmed_at: string | null
          created_at: string | null
          deleted_at: string | null
          email: string | null
          email_change: string | null
          email_change_confirm_status: number | null
          email_change_sent_at: string | null
          email_change_token_current: string | null
          email_change_token_new: string | null
          email_confirmed_at: string | null
          encrypted_password: string | null
          id: string
          instance_id: string | null
          invited_at: string | null
          is_anonymous: boolean
          is_sso_user: boolean
          is_super_admin: boolean | null
          last_sign_in_at: string | null
          phone: string | null
          phone_change: string | null
          phone_change_sent_at: string | null
          phone_change_token: string | null
          phone_confirmed_at: string | null
          raw_app_meta_data: Json | null
          raw_user_meta_data: Json | null
          reauthentication_sent_at: string | null
          reauthentication_token: string | null
          recovery_sent_at: string | null
          recovery_token: string | null
          role: string | null
          updated_at: string | null
        }
        Insert: {
          aud?: string | null
          banned_until?: string | null
          confirmation_sent_at?: string | null
          confirmation_token?: string | null
          confirmed_at?: string | null
          created_at?: string | null
          deleted_at?: string | null
          email?: string | null
          email_change?: string | null
          email_change_confirm_status?: number | null
          email_change_sent_at?: string | null
          email_change_token_current?: string | null
          email_change_token_new?: string | null
          email_confirmed_at?: string | null
          encrypted_password?: string | null
          id: string
          instance_id?: string | null
          invited_at?: string | null
          is_anonymous?: boolean
          is_sso_user?: boolean
          is_super_admin?: boolean | null
          last_sign_in_at?: string | null
          phone?: string | null
          phone_change?: string | null
          phone_change_sent_at?: string | null
          phone_change_token?: string | null
          phone_confirmed_at?: string | null
          raw_app_meta_data?: Json | null
          raw_user_meta_data?: Json | null
          reauthentication_sent_at?: string | null
          reauthentication_token?: string | null
          recovery_sent_at?: string | null
          recovery_token?: string | null
          role?: string | null
          updated_at?: string | null
        }
        Update: {
          aud?: string | null
          banned_until?: string | null
          confirmation_sent_at?: string | null
          confirmation_token?: string | null
          confirmed_at?: string | null
          created_at?: string | null
          deleted_at?: string | null
          email?: string | null
          email_change?: string | null
          email_change_confirm_status?: number | null
          email_change_sent_at?: string | null
          email_change_token_current?: string | null
          email_change_token_new?: string | null
          email_confirmed_at?: string | null
          encrypted_password?: string | null
          id?: string
          instance_id?: string | null
          invited_at?: string | null
          is_anonymous?: boolean
          is_sso_user?: boolean
          is_super_admin?: boolean | null
          last_sign_in_at?: string | null
          phone?: string | null
          phone_change?: string | null
          phone_change_sent_at?: string | null
          phone_change_token?: string | null
          phone_confirmed_at?: string | null
          raw_app_meta_data?: Json | null
          raw_user_meta_data?: Json | null
          reauthentication_sent_at?: string | null
          reauthentication_token?: string | null
          recovery_sent_at?: string | null
          recovery_token?: string | null
          role?: string | null
          updated_at?: string | null
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      email: {
        Args: Record<PropertyKey, never>
        Returns: string
      }
      jwt: {
        Args: Record<PropertyKey, never>
        Returns: Json
      }
      role: {
        Args: Record<PropertyKey, never>
        Returns: string
      }
      uid: {
        Args: Record<PropertyKey, never>
        Returns: string
      }
    }
    Enums: {
      aal_level: "aal1" | "aal2" | "aal3"
      code_challenge_method: "s256" | "plain"
      factor_status: "unverified" | "verified"
      factor_type: "totp" | "webauthn" | "phone"
      one_time_token_type:
        | "confirmation_token"
        | "reauthentication_token"
        | "recovery_token"
        | "email_change_token_new"
        | "email_change_token_current"
        | "phone_change_token"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  public: {
    Tables: {
      account_categories: {
        Row: {
          business_id: string
          category_id: string
          code: string
          created_at: string
          description: string | null
          name: string
        }
        Insert: {
          business_id: string
          category_id?: string
          code: string
          created_at?: string
          description?: string | null
          name: string
        }
        Update: {
          business_id?: string
          category_id?: string
          code?: string
          created_at?: string
          description?: string | null
          name?: string
        }
        Relationships: [
          {
            foreignKeyName: "account_categories_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "account_categories_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
        ]
      }
      accounts: {
        Row: {
          account_id: string
          balance: number
          business_id: string
          category_id: string
          code: string
          created_at: string
          description: string | null
          is_group: boolean
          is_system: boolean
          name: string
          org_id: string
          parent_account_id: string | null
        }
        Insert: {
          account_id?: string
          balance?: number
          business_id: string
          category_id: string
          code: string
          created_at?: string
          description?: string | null
          is_group?: boolean
          is_system?: boolean
          name: string
          org_id: string
          parent_account_id?: string | null
        }
        Update: {
          account_id?: string
          balance?: number
          business_id?: string
          category_id?: string
          code?: string
          created_at?: string
          description?: string | null
          is_group?: boolean
          is_system?: boolean
          name?: string
          org_id?: string
          parent_account_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "accounts_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "accounts_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "accounts_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "account_categories"
            referencedColumns: ["category_id"]
          },
          {
            foreignKeyName: "accounts_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "org_details_view"
            referencedColumns: ["org_id"]
          },
          {
            foreignKeyName: "accounts_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["org_id"]
          },
          {
            foreignKeyName: "accounts_parent_account_id_fkey"
            columns: ["parent_account_id"]
            isOneToOne: false
            referencedRelation: "accounts"
            referencedColumns: ["account_id"]
          },
        ]
      }
      addon_prices: {
        Row: {
          addon_id: number
          addon_price_id: number
          country_code: string
          created_at: string
          currency_code: string
          is_active: boolean
          price_annual: number | null
          price_monthly: number | null
          price_one_time: number | null
          updated_at: string
        }
        Insert: {
          addon_id: number
          addon_price_id?: number
          country_code: string
          created_at?: string
          currency_code: string
          is_active?: boolean
          price_annual?: number | null
          price_monthly?: number | null
          price_one_time?: number | null
          updated_at?: string
        }
        Update: {
          addon_id?: number
          addon_price_id?: number
          country_code?: string
          created_at?: string
          currency_code?: string
          is_active?: boolean
          price_annual?: number | null
          price_monthly?: number | null
          price_one_time?: number | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "addon_prices_addon_id_fkey"
            columns: ["addon_id"]
            isOneToOne: false
            referencedRelation: "addons"
            referencedColumns: ["addon_id"]
          },
        ]
      }
      addons: {
        Row: {
          addon_id: number
          addon_type: Database["public"]["Enums"]["addon_type_enum"]
          created_at: string
          default_currency: string | null
          default_price_annual: number | null
          default_price_monthly: number | null
          default_price_one_time: number | null
          description: string | null
          is_active: boolean
          linked_feature_id: number | null
          name: string
          slug: string
          unit_name: string | null
          updated_at: string
        }
        Insert: {
          addon_id?: number
          addon_type?: Database["public"]["Enums"]["addon_type_enum"]
          created_at?: string
          default_currency?: string | null
          default_price_annual?: number | null
          default_price_monthly?: number | null
          default_price_one_time?: number | null
          description?: string | null
          is_active?: boolean
          linked_feature_id?: number | null
          name: string
          slug: string
          unit_name?: string | null
          updated_at?: string
        }
        Update: {
          addon_id?: number
          addon_type?: Database["public"]["Enums"]["addon_type_enum"]
          created_at?: string
          default_currency?: string | null
          default_price_annual?: number | null
          default_price_monthly?: number | null
          default_price_one_time?: number | null
          description?: string | null
          is_active?: boolean
          linked_feature_id?: number | null
          name?: string
          slug?: string
          unit_name?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "addons_linked_feature_id_fkey"
            columns: ["linked_feature_id"]
            isOneToOne: false
            referencedRelation: "features"
            referencedColumns: ["feature_id"]
          },
        ]
      }
      brands: {
        Row: {
          brand_id: string
          business_id: string
          created_at: string
          description: string | null
          name: string
          org_id: string | null
        }
        Insert: {
          brand_id?: string
          business_id: string
          created_at?: string
          description?: string | null
          name: string
          org_id?: string | null
        }
        Update: {
          brand_id?: string
          business_id?: string
          created_at?: string
          description?: string | null
          name?: string
          org_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "brands_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "brands_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "brands_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "org_details_view"
            referencedColumns: ["org_id"]
          },
          {
            foreignKeyName: "brands_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["org_id"]
          },
        ]
      }
      business_customers: {
        Row: {
          address: string | null
          business_id: string
          created_at: string
          customer_balance: number
          customer_id: string
          image: string | null
          is_active: boolean
          name: string
          updated_at: string | null
        }
        Insert: {
          address?: string | null
          business_id: string
          created_at?: string
          customer_balance?: number
          customer_id: string
          image?: string | null
          is_active?: boolean
          name: string
          updated_at?: string | null
        }
        Update: {
          address?: string | null
          business_id?: string
          created_at?: string
          customer_balance?: number
          customer_id?: string
          image?: string | null
          is_active?: boolean
          name?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "business_customers_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "business_customers_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "business_customers_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "business_customer_view"
            referencedColumns: ["customer_id"]
          },
          {
            foreignKeyName: "business_customers_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "customer_view"
            referencedColumns: ["customer_id"]
          },
          {
            foreignKeyName: "business_customers_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "customers"
            referencedColumns: ["customer_id"]
          },
        ]
      }
      businesses: {
        Row: {
          allow_sales_when_outofstock: boolean
          allow_walkin_customer: boolean
          business_id: string
          business_type: Database["public"]["Enums"]["business_types"]
          contact_address: string | null
          contact_email: string | null
          contact_phone: string | null
          country: string | null
          created_at: string
          created_by: string | null
          currency: Json | null
          fiscal_id: string
          format: string
          gst_in: string | null
          gst_registered_date: string | null
          images: string[] | null
          is_gst_registered: boolean | null
          last_active_at: string | null
          legal_business_name: string | null
          logo: string | null
          name: string
          org_id: string
          print_barcode_on_purchase: boolean | null
          print_on_purchase: boolean
          print_on_sale: boolean
          state: string | null
          store_name: string | null
          subscription_status: Database["public"]["Enums"]["subscription_status"]
          time_zone: string | null
          trade_name: string | null
        }
        Insert: {
          allow_sales_when_outofstock?: boolean
          allow_walkin_customer?: boolean
          business_id?: string
          business_type?: Database["public"]["Enums"]["business_types"]
          contact_address?: string | null
          contact_email?: string | null
          contact_phone?: string | null
          country?: string | null
          created_at?: string
          created_by?: string | null
          currency?: Json | null
          fiscal_id?: string
          format?: string
          gst_in?: string | null
          gst_registered_date?: string | null
          images?: string[] | null
          is_gst_registered?: boolean | null
          last_active_at?: string | null
          legal_business_name?: string | null
          logo?: string | null
          name: string
          org_id: string
          print_barcode_on_purchase?: boolean | null
          print_on_purchase?: boolean
          print_on_sale?: boolean
          state?: string | null
          store_name?: string | null
          subscription_status?: Database["public"]["Enums"]["subscription_status"]
          time_zone?: string | null
          trade_name?: string | null
        }
        Update: {
          allow_sales_when_outofstock?: boolean
          allow_walkin_customer?: boolean
          business_id?: string
          business_type?: Database["public"]["Enums"]["business_types"]
          contact_address?: string | null
          contact_email?: string | null
          contact_phone?: string | null
          country?: string | null
          created_at?: string
          created_by?: string | null
          currency?: Json | null
          fiscal_id?: string
          format?: string
          gst_in?: string | null
          gst_registered_date?: string | null
          images?: string[] | null
          is_gst_registered?: boolean | null
          last_active_at?: string | null
          legal_business_name?: string | null
          logo?: string | null
          name?: string
          org_id?: string
          print_barcode_on_purchase?: boolean | null
          print_on_purchase?: boolean
          print_on_sale?: boolean
          state?: string | null
          store_name?: string | null
          subscription_status?: Database["public"]["Enums"]["subscription_status"]
          time_zone?: string | null
          trade_name?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "businesses_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "employee_view"
            referencedColumns: ["employee_id"]
          },
          {
            foreignKeyName: "businesses_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "employees"
            referencedColumns: ["employee_id"]
          },
          {
            foreignKeyName: "businesses_fiscal_id_fkey"
            columns: ["fiscal_id"]
            isOneToOne: false
            referencedRelation: "fiscal_years"
            referencedColumns: ["fiscal_id"]
          },
          {
            foreignKeyName: "businesses_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "org_details_view"
            referencedColumns: ["org_id"]
          },
          {
            foreignKeyName: "businesses_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["org_id"]
          },
        ]
      }
      cities: {
        Row: {
          id: number
          name: string
          state_id: number | null
        }
        Insert: {
          id?: number
          name: string
          state_id?: number | null
        }
        Update: {
          id?: number
          name?: string
          state_id?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "cities_state_id_fkey"
            columns: ["state_id"]
            isOneToOne: false
            referencedRelation: "states"
            referencedColumns: ["id"]
          },
        ]
      }
      countries: {
        Row: {
          currency: string | null
          emoji: string | null
          emoji_u: string | null
          id: number
          iso_code: string
          name: string
        }
        Insert: {
          currency?: string | null
          emoji?: string | null
          emoji_u?: string | null
          id?: number
          iso_code: string
          name: string
        }
        Update: {
          currency?: string | null
          emoji?: string | null
          emoji_u?: string | null
          id?: number
          iso_code?: string
          name?: string
        }
        Relationships: []
      }
      customers: {
        Row: {
          created_at: string
          customer_id: string
          image: string | null
          name: string
        }
        Insert: {
          created_at?: string
          customer_id: string
          image?: string | null
          name?: string
        }
        Update: {
          created_at?: string
          customer_id?: string
          image?: string | null
          name?: string
        }
        Relationships: [
          {
            foreignKeyName: "customers_user_id_fkey"
            columns: ["customer_id"]
            isOneToOne: true
            referencedRelation: "users"
            referencedColumns: ["user_id"]
          },
        ]
      }
      employee_branch_access: {
        Row: {
          business_id: string
          created_at: string
          employee_id: string
        }
        Insert: {
          business_id: string
          created_at?: string
          employee_id: string
        }
        Update: {
          business_id?: string
          created_at?: string
          employee_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "employee_branch_access_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "employee_branch_access_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "employee_branch_access_employee_id_fkey"
            columns: ["employee_id"]
            isOneToOne: false
            referencedRelation: "employee_view"
            referencedColumns: ["employee_id"]
          },
          {
            foreignKeyName: "employee_branch_access_employee_id_fkey"
            columns: ["employee_id"]
            isOneToOne: false
            referencedRelation: "employees"
            referencedColumns: ["employee_id"]
          },
        ]
      }
      employee_roles: {
        Row: {
          business_id: string | null
          created_at: string
          description: string | null
          editable: boolean
          employee_role_id: string
          name: string
        }
        Insert: {
          business_id?: string | null
          created_at?: string
          description?: string | null
          editable?: boolean
          employee_role_id?: string
          name: string
        }
        Update: {
          business_id?: string | null
          created_at?: string
          description?: string | null
          editable?: boolean
          employee_role_id?: string
          name?: string
        }
        Relationships: [
          {
            foreignKeyName: "employee_roles_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "employee_roles_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "user_roles_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "user_roles_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
        ]
      }
      employees: {
        Row: {
          code: string | null
          created_at: string
          employee_id: string
          image: string | null
          name: string
          org_id: string
          role: Database["public"]["Enums"]["employee_type"]
        }
        Insert: {
          code?: string | null
          created_at?: string
          employee_id: string
          image?: string | null
          name?: string
          org_id: string
          role?: Database["public"]["Enums"]["employee_type"]
        }
        Update: {
          code?: string | null
          created_at?: string
          employee_id?: string
          image?: string | null
          name?: string
          org_id?: string
          role?: Database["public"]["Enums"]["employee_type"]
        }
        Relationships: [
          {
            foreignKeyName: "employees_employee_id_fkey"
            columns: ["employee_id"]
            isOneToOne: true
            referencedRelation: "users"
            referencedColumns: ["user_id"]
          },
          {
            foreignKeyName: "employees_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "org_details_view"
            referencedColumns: ["org_id"]
          },
          {
            foreignKeyName: "employees_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["org_id"]
          },
        ]
      }
      expense_categories: {
        Row: {
          business_id: string
          category_id: string
          created_at: string | null
          description: string | null
          icon_info: Json | null
          name: string
        }
        Insert: {
          business_id: string
          category_id?: string
          created_at?: string | null
          description?: string | null
          icon_info?: Json | null
          name: string
        }
        Update: {
          business_id?: string
          category_id?: string
          created_at?: string | null
          description?: string | null
          icon_info?: Json | null
          name?: string
        }
        Relationships: [
          {
            foreignKeyName: "expense_category_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "expense_category_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
        ]
      }
      expenses: {
        Row: {
          amount: number
          business_id: string
          created_at: string
          date: string
          expense_category_id: string | null
          expense_for: string
          expense_id: string
          note: string | null
          payment_type: Database["public"]["Enums"]["payment_type"]
          reference_number: string | null
          status: string | null
          transaction_id: string | null
        }
        Insert: {
          amount: number
          business_id: string
          created_at?: string
          date: string
          expense_category_id?: string | null
          expense_for: string
          expense_id?: string
          note?: string | null
          payment_type: Database["public"]["Enums"]["payment_type"]
          reference_number?: string | null
          status?: string | null
          transaction_id?: string | null
        }
        Update: {
          amount?: number
          business_id?: string
          created_at?: string
          date?: string
          expense_category_id?: string | null
          expense_for?: string
          expense_id?: string
          note?: string | null
          payment_type?: Database["public"]["Enums"]["payment_type"]
          reference_number?: string | null
          status?: string | null
          transaction_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "expenses_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "expenses_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "expenses_expense_category_id_fkey"
            columns: ["expense_category_id"]
            isOneToOne: false
            referencedRelation: "expense_categories"
            referencedColumns: ["category_id"]
          },
          {
            foreignKeyName: "expenses_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "daily_transactions_report"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "expenses_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "transactions"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "expenses_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "vw_daily_transactions_report_v2"
            referencedColumns: ["transaction_id"]
          },
        ]
      }
      features: {
        Row: {
          created_at: string
          description: string | null
          feature_id: number
          feature_type: Database["public"]["Enums"]["feature_type_enum"]
          name: string
          slug: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          description?: string | null
          feature_id?: number
          feature_type?: Database["public"]["Enums"]["feature_type_enum"]
          name: string
          slug: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          description?: string | null
          feature_id?: number
          feature_type?: Database["public"]["Enums"]["feature_type_enum"]
          name?: string
          slug?: string
          updated_at?: string
        }
        Relationships: []
      }
      fiscal_years: {
        Row: {
          end_month: number
          fiscal_id: string
          name: string
          start_month: number
        }
        Insert: {
          end_month: number
          fiscal_id?: string
          name: string
          start_month: number
        }
        Update: {
          end_month?: number
          fiscal_id?: string
          name?: string
          start_month?: number
        }
        Relationships: []
      }
      income_categories: {
        Row: {
          business_id: string
          category_id: string
          created_at: string | null
          description: string | null
          icon_info: Json | null
          name: string
        }
        Insert: {
          business_id: string
          category_id?: string
          created_at?: string | null
          description?: string | null
          icon_info?: Json | null
          name: string
        }
        Update: {
          business_id?: string
          category_id?: string
          created_at?: string | null
          description?: string | null
          icon_info?: Json | null
          name?: string
        }
        Relationships: [
          {
            foreignKeyName: "income_category_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "income_category_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
        ]
      }
      incomes: {
        Row: {
          amount: number
          business_id: string
          created_at: string
          date: string
          income_category_id: string | null
          income_for: string
          income_id: string
          note: string | null
          payment_type: Database["public"]["Enums"]["payment_type"]
          reference_number: string | null
          status: string | null
          transaction_id: string | null
        }
        Insert: {
          amount: number
          business_id: string
          created_at?: string
          date: string
          income_category_id?: string | null
          income_for: string
          income_id?: string
          note?: string | null
          payment_type: Database["public"]["Enums"]["payment_type"]
          reference_number?: string | null
          status?: string | null
          transaction_id?: string | null
        }
        Update: {
          amount?: number
          business_id?: string
          created_at?: string
          date?: string
          income_category_id?: string | null
          income_for?: string
          income_id?: string
          note?: string | null
          payment_type?: Database["public"]["Enums"]["payment_type"]
          reference_number?: string | null
          status?: string | null
          transaction_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "incomes_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "incomes_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "incomes_income_category_id_fkey"
            columns: ["income_category_id"]
            isOneToOne: false
            referencedRelation: "income_categories"
            referencedColumns: ["category_id"]
          },
          {
            foreignKeyName: "incomes_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "daily_transactions_report"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "incomes_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "transactions"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "incomes_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "vw_daily_transactions_report_v2"
            referencedColumns: ["transaction_id"]
          },
        ]
      }
      item_categories: {
        Row: {
          business_id: string
          created_at: string
          description: string | null
          icon_info: Json | null
          item_category_id: string
          name: string
          org_id: string | null
        }
        Insert: {
          business_id: string
          created_at?: string
          description?: string | null
          icon_info?: Json | null
          item_category_id?: string
          name: string
          org_id?: string | null
        }
        Update: {
          business_id?: string
          created_at?: string
          description?: string | null
          icon_info?: Json | null
          item_category_id?: string
          name?: string
          org_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "item_categories_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "item_categories_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "item_categories_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "org_details_view"
            referencedColumns: ["org_id"]
          },
          {
            foreignKeyName: "item_categories_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["org_id"]
          },
        ]
      }
      item_custom_field_definitions: {
        Row: {
          business_id: string
          created_at: string
          default_value: string | null
          field_id: string
          field_name: string
          field_type: Database["public"]["Enums"]["custom_field_type"]
          is_required: boolean
          validation_rules: Json | null
        }
        Insert: {
          business_id: string
          created_at?: string
          default_value?: string | null
          field_id?: string
          field_name: string
          field_type: Database["public"]["Enums"]["custom_field_type"]
          is_required?: boolean
          validation_rules?: Json | null
        }
        Update: {
          business_id?: string
          created_at?: string
          default_value?: string | null
          field_id?: string
          field_name?: string
          field_type?: Database["public"]["Enums"]["custom_field_type"]
          is_required?: boolean
          validation_rules?: Json | null
        }
        Relationships: [
          {
            foreignKeyName: "item_custom_field_definitions_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "item_custom_field_definitions_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
        ]
      }
      item_custom_field_values: {
        Row: {
          created_at: string
          field_id: string
          field_value: string | null
          item_id: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          field_id: string
          field_value?: string | null
          item_id: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          field_id?: string
          field_value?: string | null
          item_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "item_custom_field_values_field_id_fkey"
            columns: ["field_id"]
            isOneToOne: false
            referencedRelation: "item_custom_field_definitions"
            referencedColumns: ["field_id"]
          },
          {
            foreignKeyName: "item_custom_field_values_item_id_fkey"
            columns: ["item_id"]
            isOneToOne: false
            referencedRelation: "items"
            referencedColumns: ["item_id"]
          },
          {
            foreignKeyName: "item_custom_field_values_item_id_fkey"
            columns: ["item_id"]
            isOneToOne: false
            referencedRelation: "vw_items"
            referencedColumns: ["item_id"]
          },
        ]
      }
      items: {
        Row: {
          alert_quantity: number
          branch_variant_id: string
          brand_id: string | null
          business_id: string
          created_at: string
          images: Json[] | null
          inventory_enabled: boolean
          is_active: boolean
          is_returnable: boolean
          item_category_id: string | null
          item_code: string | null
          item_id: string
          item_type: Database["public"]["Enums"]["item_type"]
          name: string
          opening_stock_qty: number
          opening_stock_value: number
          org_id: string
          preferred_vendor_id: string | null
          purchase_enabled: boolean
          purchase_price: number | null
          quantity: number
          retail_price: number | null
          rich_text: Json | null
          sale_price: number
          sales_enabled: boolean
          serial_nos: string[] | null
          stock_quantity: number
          stock_value: number
          tax_id: string | null
          unit_id: string | null
          updated_at: string | null
        }
        Insert: {
          alert_quantity?: number
          branch_variant_id?: string
          brand_id?: string | null
          business_id: string
          created_at?: string
          images?: Json[] | null
          inventory_enabled?: boolean
          is_active?: boolean
          is_returnable?: boolean
          item_category_id?: string | null
          item_code?: string | null
          item_id?: string
          item_type: Database["public"]["Enums"]["item_type"]
          name: string
          opening_stock_qty?: number
          opening_stock_value?: number
          org_id: string
          preferred_vendor_id?: string | null
          purchase_enabled?: boolean
          purchase_price?: number | null
          quantity?: number
          retail_price?: number | null
          rich_text?: Json | null
          sale_price?: number
          sales_enabled?: boolean
          serial_nos?: string[] | null
          stock_quantity?: number
          stock_value?: number
          tax_id?: string | null
          unit_id?: string | null
          updated_at?: string | null
        }
        Update: {
          alert_quantity?: number
          branch_variant_id?: string
          brand_id?: string | null
          business_id?: string
          created_at?: string
          images?: Json[] | null
          inventory_enabled?: boolean
          is_active?: boolean
          is_returnable?: boolean
          item_category_id?: string | null
          item_code?: string | null
          item_id?: string
          item_type?: Database["public"]["Enums"]["item_type"]
          name?: string
          opening_stock_qty?: number
          opening_stock_value?: number
          org_id?: string
          preferred_vendor_id?: string | null
          purchase_enabled?: boolean
          purchase_price?: number | null
          quantity?: number
          retail_price?: number | null
          rich_text?: Json | null
          sale_price?: number
          sales_enabled?: boolean
          serial_nos?: string[] | null
          stock_quantity?: number
          stock_value?: number
          tax_id?: string | null
          unit_id?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "items_brand_id_fkey"
            columns: ["brand_id"]
            isOneToOne: false
            referencedRelation: "brands"
            referencedColumns: ["brand_id"]
          },
          {
            foreignKeyName: "items_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "items_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "items_item_category_id_fkey"
            columns: ["item_category_id"]
            isOneToOne: false
            referencedRelation: "item_categories"
            referencedColumns: ["item_category_id"]
          },
          {
            foreignKeyName: "items_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "org_details_view"
            referencedColumns: ["org_id"]
          },
          {
            foreignKeyName: "items_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["org_id"]
          },
          {
            foreignKeyName: "items_preferred_vendor_id_fkey"
            columns: ["preferred_vendor_id"]
            isOneToOne: false
            referencedRelation: "suppliers"
            referencedColumns: ["supplier_id"]
          },
          {
            foreignKeyName: "items_tax_id_fkey"
            columns: ["tax_id"]
            isOneToOne: false
            referencedRelation: "taxes"
            referencedColumns: ["tax_id"]
          },
          {
            foreignKeyName: "items_unit_id_fkey"
            columns: ["unit_id"]
            isOneToOne: false
            referencedRelation: "units"
            referencedColumns: ["unit_id"]
          },
        ]
      }
      links: {
        Row: {
          created_at: string
          description: string | null
          link_id: number
          module_id: number
          name: string
          sort_order: number
          url: string
          visibility: boolean
        }
        Insert: {
          created_at?: string
          description?: string | null
          link_id?: number
          module_id: number
          name: string
          sort_order?: number
          url: string
          visibility?: boolean
        }
        Update: {
          created_at?: string
          description?: string | null
          link_id?: number
          module_id?: number
          name?: string
          sort_order?: number
          url?: string
          visibility?: boolean
        }
        Relationships: [
          {
            foreignKeyName: "public_links_module_id_fkey"
            columns: ["module_id"]
            isOneToOne: false
            referencedRelation: "modules"
            referencedColumns: ["module_id"]
          },
        ]
      }
      modules: {
        Row: {
          created_at: string
          description: string | null
          module_id: number
          name: string
          sort_order: number
          url: string
        }
        Insert: {
          created_at?: string
          description?: string | null
          module_id?: number
          name: string
          sort_order?: number
          url: string
        }
        Update: {
          created_at?: string
          description?: string | null
          module_id?: number
          name?: string
          sort_order?: number
          url?: string
        }
        Relationships: []
      }
      organizations: {
        Row: {
          created_at: string
          created_by: string | null
          name: string | null
          org_id: string
          trial_activated: boolean
        }
        Insert: {
          created_at?: string
          created_by?: string | null
          name?: string | null
          org_id?: string
          trial_activated?: boolean
        }
        Update: {
          created_at?: string
          created_by?: string | null
          name?: string | null
          org_id?: string
          trial_activated?: boolean
        }
        Relationships: [
          {
            foreignKeyName: "organizations_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: true
            referencedRelation: "employee_view"
            referencedColumns: ["employee_id"]
          },
          {
            foreignKeyName: "organizations_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: true
            referencedRelation: "employees"
            referencedColumns: ["employee_id"]
          },
        ]
      }
      payments: {
        Row: {
          amount: number
          created_at: string
          created_by: string
          metadata: Json | null
          notes: string | null
          payment_date: string
          payment_id: string
          payment_method: string
          reference_no: string | null
          transaction_id: string
        }
        Insert: {
          amount: number
          created_at?: string
          created_by: string
          metadata?: Json | null
          notes?: string | null
          payment_date: string
          payment_id?: string
          payment_method: string
          reference_no?: string | null
          transaction_id: string
        }
        Update: {
          amount?: number
          created_at?: string
          created_by?: string
          metadata?: Json | null
          notes?: string | null
          payment_date?: string
          payment_id?: string
          payment_method?: string
          reference_no?: string | null
          transaction_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "payments_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["user_id"]
          },
          {
            foreignKeyName: "payments_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "daily_transactions_report"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "payments_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "transactions"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "payments_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "vw_daily_transactions_report_v2"
            referencedColumns: ["transaction_id"]
          },
        ]
      }
      permissions: {
        Row: {
          create: boolean
          created_at: string
          delete: boolean
          edit: boolean
          employee_role_id: string
          link_id: number | null
          module_id: number | null
          permission_id: string
          print: boolean
          view: boolean
        }
        Insert: {
          create?: boolean
          created_at?: string
          delete?: boolean
          edit?: boolean
          employee_role_id: string
          link_id?: number | null
          module_id?: number | null
          permission_id?: string
          print?: boolean
          view?: boolean
        }
        Update: {
          create?: boolean
          created_at?: string
          delete?: boolean
          edit?: boolean
          employee_role_id?: string
          link_id?: number | null
          module_id?: number | null
          permission_id?: string
          print?: boolean
          view?: boolean
        }
        Relationships: [
          {
            foreignKeyName: "permissions_link_id_fkey"
            columns: ["link_id"]
            isOneToOne: false
            referencedRelation: "links"
            referencedColumns: ["link_id"]
          },
          {
            foreignKeyName: "permissions_role_id_fkey"
            columns: ["employee_role_id"]
            isOneToOne: false
            referencedRelation: "employee_roles"
            referencedColumns: ["employee_role_id"]
          },
          {
            foreignKeyName: "public_permissions_module_id_fkey"
            columns: ["module_id"]
            isOneToOne: false
            referencedRelation: "modules"
            referencedColumns: ["module_id"]
          },
        ]
      }
      plan_features: {
        Row: {
          created_at: string
          feature_id: number
          is_enabled: boolean
          limit_value: number | null
          plan_feature_id: number
          plan_id: number
          updated_at: string
        }
        Insert: {
          created_at?: string
          feature_id: number
          is_enabled?: boolean
          limit_value?: number | null
          plan_feature_id?: number
          plan_id: number
          updated_at?: string
        }
        Update: {
          created_at?: string
          feature_id?: number
          is_enabled?: boolean
          limit_value?: number | null
          plan_feature_id?: number
          plan_id?: number
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "plan_features_feature_id_fkey"
            columns: ["feature_id"]
            isOneToOne: false
            referencedRelation: "features"
            referencedColumns: ["feature_id"]
          },
          {
            foreignKeyName: "plan_features_plan_id_fkey"
            columns: ["plan_id"]
            isOneToOne: false
            referencedRelation: "plans"
            referencedColumns: ["plan_id"]
          },
        ]
      }
      plan_prices: {
        Row: {
          country_code: string
          created_at: string
          currency_code: string
          is_active: boolean
          plan_id: number
          plan_price_id: number
          price_annual: number
          price_monthly: number
          updated_at: string
        }
        Insert: {
          country_code: string
          created_at?: string
          currency_code: string
          is_active?: boolean
          plan_id: number
          plan_price_id?: number
          price_annual: number
          price_monthly: number
          updated_at?: string
        }
        Update: {
          country_code?: string
          created_at?: string
          currency_code?: string
          is_active?: boolean
          plan_id?: number
          plan_price_id?: number
          price_annual?: number
          price_monthly?: number
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "plan_prices_plan_id_fkey"
            columns: ["plan_id"]
            isOneToOne: false
            referencedRelation: "plans"
            referencedColumns: ["plan_id"]
          },
        ]
      }
      plans: {
        Row: {
          created_at: string
          default_currency: string | null
          default_price_annual: number | null
          default_price_monthly: number | null
          description: string | null
          display_order: number
          is_active: boolean
          name: string
          plan_id: number
          slug: string
          trial_period_days: number | null
          updated_at: string
        }
        Insert: {
          created_at?: string
          default_currency?: string | null
          default_price_annual?: number | null
          default_price_monthly?: number | null
          description?: string | null
          display_order?: number
          is_active?: boolean
          name: string
          plan_id?: number
          slug: string
          trial_period_days?: number | null
          updated_at?: string
        }
        Update: {
          created_at?: string
          default_currency?: string | null
          default_price_annual?: number | null
          default_price_monthly?: number | null
          description?: string | null
          display_order?: number
          is_active?: boolean
          name?: string
          plan_id?: number
          slug?: string
          trial_period_days?: number | null
          updated_at?: string
        }
        Relationships: []
      }
      processed_webhook_events: {
        Row: {
          created_at: string
          event_id: string
        }
        Insert: {
          created_at?: string
          event_id: string
        }
        Update: {
          created_at?: string
          event_id?: string
        }
        Relationships: []
      }
      purchase_audits: {
        Row: {
          action_timestamp: string
          action_type: Database["public"]["Enums"]["purchase_audit_action"]
          audit_id: string
          change_details: string | null
          ip_address: string | null
          new_data: Json | null
          old_data: Json | null
          performed_by: string
          purchase_id: string
          transaction_id: string
          user_agent: string | null
        }
        Insert: {
          action_timestamp?: string
          action_type: Database["public"]["Enums"]["purchase_audit_action"]
          audit_id?: string
          change_details?: string | null
          ip_address?: string | null
          new_data?: Json | null
          old_data?: Json | null
          performed_by: string
          purchase_id: string
          transaction_id: string
          user_agent?: string | null
        }
        Update: {
          action_timestamp?: string
          action_type?: Database["public"]["Enums"]["purchase_audit_action"]
          audit_id?: string
          change_details?: string | null
          ip_address?: string | null
          new_data?: Json | null
          old_data?: Json | null
          performed_by?: string
          purchase_id?: string
          transaction_id?: string
          user_agent?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "purchase_audits_performed_by_fkey"
            columns: ["performed_by"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["user_id"]
          },
          {
            foreignKeyName: "purchase_audits_purchase_id_fkey"
            columns: ["purchase_id"]
            isOneToOne: false
            referencedRelation: "purchase_view"
            referencedColumns: ["purchase_id"]
          },
          {
            foreignKeyName: "purchase_audits_purchase_id_fkey"
            columns: ["purchase_id"]
            isOneToOne: false
            referencedRelation: "purchases"
            referencedColumns: ["purchase_id"]
          },
          {
            foreignKeyName: "purchase_audits_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "daily_transactions_report"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "purchase_audits_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "transactions"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "purchase_audits_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "vw_daily_transactions_report_v2"
            referencedColumns: ["transaction_id"]
          },
        ]
      }
      purchase_custom_field_definitions: {
        Row: {
          business_id: string
          created_at: string
          default_value: string | null
          field_id: string
          field_name: string
          field_type: Database["public"]["Enums"]["custom_field_type"]
          is_required: boolean
          updated_at: string
          validation_rules: Json | null
        }
        Insert: {
          business_id: string
          created_at?: string
          default_value?: string | null
          field_id?: string
          field_name: string
          field_type: Database["public"]["Enums"]["custom_field_type"]
          is_required?: boolean
          updated_at?: string
          validation_rules?: Json | null
        }
        Update: {
          business_id?: string
          created_at?: string
          default_value?: string | null
          field_id?: string
          field_name?: string
          field_type?: Database["public"]["Enums"]["custom_field_type"]
          is_required?: boolean
          updated_at?: string
          validation_rules?: Json | null
        }
        Relationships: [
          {
            foreignKeyName: "purchase_custom_field_definitions_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "purchase_custom_field_definitions_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
        ]
      }
      purchase_custom_field_values: {
        Row: {
          created_at: string
          field_id: string
          field_value: string | null
          purchase_id: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          field_id: string
          field_value?: string | null
          purchase_id: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          field_id?: string
          field_value?: string | null
          purchase_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "purchase_custom_field_values_field_id_fkey"
            columns: ["field_id"]
            isOneToOne: false
            referencedRelation: "purchase_custom_field_definitions"
            referencedColumns: ["field_id"]
          },
          {
            foreignKeyName: "purchase_custom_field_values_purchase_id_fkey"
            columns: ["purchase_id"]
            isOneToOne: false
            referencedRelation: "purchase_view"
            referencedColumns: ["purchase_id"]
          },
          {
            foreignKeyName: "purchase_custom_field_values_purchase_id_fkey"
            columns: ["purchase_id"]
            isOneToOne: false
            referencedRelation: "purchases"
            referencedColumns: ["purchase_id"]
          },
        ]
      }
      purchase_items: {
        Row: {
          created_at: string
          item_id: string
          purchase_id: string
          purchase_item_id: string
          quantity: number
          total_price: number | null
          unit_price: number
          updated_at: string
        }
        Insert: {
          created_at?: string
          item_id: string
          purchase_id: string
          purchase_item_id?: string
          quantity?: number
          total_price?: number | null
          unit_price?: number
          updated_at?: string
        }
        Update: {
          created_at?: string
          item_id?: string
          purchase_id?: string
          purchase_item_id?: string
          quantity?: number
          total_price?: number | null
          unit_price?: number
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "purchase_items_item_id_fkey"
            columns: ["item_id"]
            isOneToOne: false
            referencedRelation: "items"
            referencedColumns: ["item_id"]
          },
          {
            foreignKeyName: "purchase_items_item_id_fkey"
            columns: ["item_id"]
            isOneToOne: false
            referencedRelation: "vw_items"
            referencedColumns: ["item_id"]
          },
          {
            foreignKeyName: "purchase_items_purchase_id_fkey"
            columns: ["purchase_id"]
            isOneToOne: false
            referencedRelation: "purchase_view"
            referencedColumns: ["purchase_id"]
          },
          {
            foreignKeyName: "purchase_items_purchase_id_fkey"
            columns: ["purchase_id"]
            isOneToOne: false
            referencedRelation: "purchases"
            referencedColumns: ["purchase_id"]
          },
        ]
      }
      purchase_return_items: {
        Row: {
          created_at: string
          purchase_item_id: string
          quantity: number
          return_id: string
          return_item_id: string
          total_price: number | null
          unit_price: number
          updated_at: string
        }
        Insert: {
          created_at?: string
          purchase_item_id: string
          quantity?: number
          return_id: string
          return_item_id?: string
          total_price?: number | null
          unit_price?: number
          updated_at?: string
        }
        Update: {
          created_at?: string
          purchase_item_id?: string
          quantity?: number
          return_id?: string
          return_item_id?: string
          total_price?: number | null
          unit_price?: number
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "purchase_return_items_purchase_item_id_fkey"
            columns: ["purchase_item_id"]
            isOneToOne: false
            referencedRelation: "purchase_items"
            referencedColumns: ["purchase_item_id"]
          },
          {
            foreignKeyName: "purchase_return_items_return_id_fkey"
            columns: ["return_id"]
            isOneToOne: false
            referencedRelation: "purchase_returns"
            referencedColumns: ["return_id"]
          },
          {
            foreignKeyName: "purchase_return_items_return_id_fkey"
            columns: ["return_id"]
            isOneToOne: false
            referencedRelation: "v_purchase_returns"
            referencedColumns: ["return_id"]
          },
        ]
      }
      purchase_returns: {
        Row: {
          business_id: string
          created_at: string
          created_by: string
          notes: string | null
          purchase_id: string
          reason: string | null
          return_date: string
          return_id: string
          return_invoice: string
          total_amount: number
          transaction_id: string
          updated_at: string
        }
        Insert: {
          business_id: string
          created_at?: string
          created_by?: string
          notes?: string | null
          purchase_id: string
          reason?: string | null
          return_date: string
          return_id?: string
          return_invoice: string
          total_amount?: number
          transaction_id: string
          updated_at?: string
        }
        Update: {
          business_id?: string
          created_at?: string
          created_by?: string
          notes?: string | null
          purchase_id?: string
          reason?: string | null
          return_date?: string
          return_id?: string
          return_invoice?: string
          total_amount?: number
          transaction_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "purchase_returns_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "purchase_returns_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "purchase_returns_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "employee_view"
            referencedColumns: ["employee_id"]
          },
          {
            foreignKeyName: "purchase_returns_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "employees"
            referencedColumns: ["employee_id"]
          },
          {
            foreignKeyName: "purchase_returns_purchase_id_fkey"
            columns: ["purchase_id"]
            isOneToOne: false
            referencedRelation: "purchase_view"
            referencedColumns: ["purchase_id"]
          },
          {
            foreignKeyName: "purchase_returns_purchase_id_fkey"
            columns: ["purchase_id"]
            isOneToOne: false
            referencedRelation: "purchases"
            referencedColumns: ["purchase_id"]
          },
          {
            foreignKeyName: "purchase_returns_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "daily_transactions_report"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "purchase_returns_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "transactions"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "purchase_returns_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "vw_daily_transactions_report_v2"
            referencedColumns: ["transaction_id"]
          },
        ]
      }
      purchases: {
        Row: {
          attachment_url: string | null
          business_id: string
          created_at: string
          created_by: string
          discount_amount: number
          due_amount: number
          invoice_no: string
          metadata: Json | null
          notes: string | null
          paid_amount: number
          purchase_date: string
          purchase_id: string
          purchase_invoice: string | null
          shipping_charge: number
          subtotal: number
          supplier_id: string
          tax_amount: number
          total_amount: number
          transaction_id: string
          updated_at: string
        }
        Insert: {
          attachment_url?: string | null
          business_id: string
          created_at?: string
          created_by?: string
          discount_amount?: number
          due_amount?: number
          invoice_no: string
          metadata?: Json | null
          notes?: string | null
          paid_amount?: number
          purchase_date: string
          purchase_id?: string
          purchase_invoice?: string | null
          shipping_charge?: number
          subtotal?: number
          supplier_id: string
          tax_amount?: number
          total_amount?: number
          transaction_id: string
          updated_at?: string
        }
        Update: {
          attachment_url?: string | null
          business_id?: string
          created_at?: string
          created_by?: string
          discount_amount?: number
          due_amount?: number
          invoice_no?: string
          metadata?: Json | null
          notes?: string | null
          paid_amount?: number
          purchase_date?: string
          purchase_id?: string
          purchase_invoice?: string | null
          shipping_charge?: number
          subtotal?: number
          supplier_id?: string
          tax_amount?: number
          total_amount?: number
          transaction_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "purchases_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "purchases_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "purchases_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "employee_view"
            referencedColumns: ["employee_id"]
          },
          {
            foreignKeyName: "purchases_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "employees"
            referencedColumns: ["employee_id"]
          },
          {
            foreignKeyName: "purchases_supplier_id_fkey"
            columns: ["supplier_id"]
            isOneToOne: false
            referencedRelation: "suppliers"
            referencedColumns: ["supplier_id"]
          },
          {
            foreignKeyName: "purchases_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: true
            referencedRelation: "daily_transactions_report"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "purchases_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: true
            referencedRelation: "transactions"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "purchases_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: true
            referencedRelation: "vw_daily_transactions_report_v2"
            referencedColumns: ["transaction_id"]
          },
        ]
      }
      razorpay_addons: {
        Row: {
          addon_id: number
          billing_cycle: Database["public"]["Enums"]["billing_cycle_enum"]
          created_at: string
          razorpay_addon_id: string
        }
        Insert: {
          addon_id: number
          billing_cycle: Database["public"]["Enums"]["billing_cycle_enum"]
          created_at?: string
          razorpay_addon_id: string
        }
        Update: {
          addon_id?: number
          billing_cycle?: Database["public"]["Enums"]["billing_cycle_enum"]
          created_at?: string
          razorpay_addon_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "razorpay_addons_addon_id_fkey"
            columns: ["addon_id"]
            isOneToOne: false
            referencedRelation: "addons"
            referencedColumns: ["addon_id"]
          },
        ]
      }
      razorpay_plans: {
        Row: {
          billing_cycle: Database["public"]["Enums"]["billing_cycle_enum"]
          created_at: string
          plan_id: number
          razorpay_plan_id: string
        }
        Insert: {
          billing_cycle: Database["public"]["Enums"]["billing_cycle_enum"]
          created_at?: string
          plan_id: number
          razorpay_plan_id: string
        }
        Update: {
          billing_cycle?: Database["public"]["Enums"]["billing_cycle_enum"]
          created_at?: string
          plan_id?: number
          razorpay_plan_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "razorpay_plans_plan_id_fkey"
            columns: ["plan_id"]
            isOneToOne: false
            referencedRelation: "plans"
            referencedColumns: ["plan_id"]
          },
        ]
      }
      referrals: {
        Row: {
          business_id: string
          referral_id: string
          referred_at: string
          reseller_id: string
        }
        Insert: {
          business_id: string
          referral_id?: string
          referred_at?: string
          reseller_id: string
        }
        Update: {
          business_id?: string
          referral_id?: string
          referred_at?: string
          reseller_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "referrals_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "referrals_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "referrals_reseller_id_fkey"
            columns: ["reseller_id"]
            isOneToOne: false
            referencedRelation: "resellers"
            referencedColumns: ["reseller_id"]
          },
        ]
      }
      resellers: {
        Row: {
          address: string
          created_at: string
          email: string
          name: string
          phone: string
          reseller_id: string
        }
        Insert: {
          address: string
          created_at?: string
          email: string
          name: string
          phone: string
          reseller_id?: string
        }
        Update: {
          address?: string
          created_at?: string
          email?: string
          name?: string
          phone?: string
          reseller_id?: string
        }
        Relationships: []
      }
      roles_of_employees: {
        Row: {
          created_at: string
          employee_id: string
          employee_role_id: string
        }
        Insert: {
          created_at?: string
          employee_id: string
          employee_role_id: string
        }
        Update: {
          created_at?: string
          employee_id?: string
          employee_role_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "roles_of_employees_employee_id_fkey"
            columns: ["employee_id"]
            isOneToOne: false
            referencedRelation: "employee_view"
            referencedColumns: ["employee_id"]
          },
          {
            foreignKeyName: "roles_of_employees_employee_id_fkey"
            columns: ["employee_id"]
            isOneToOne: false
            referencedRelation: "employees"
            referencedColumns: ["employee_id"]
          },
          {
            foreignKeyName: "roles_of_employees_employee_role_id_fkey"
            columns: ["employee_role_id"]
            isOneToOne: false
            referencedRelation: "employee_roles"
            referencedColumns: ["employee_role_id"]
          },
        ]
      }
      sale_audits: {
        Row: {
          action_timestamp: string
          action_type: Database["public"]["Enums"]["sale_audit_action"]
          audit_id: string
          change_details: string | null
          ip_address: string | null
          new_data: Json | null
          old_data: Json | null
          performed_by: string
          sale_id: string
          transaction_id: string
          user_agent: string | null
        }
        Insert: {
          action_timestamp?: string
          action_type: Database["public"]["Enums"]["sale_audit_action"]
          audit_id?: string
          change_details?: string | null
          ip_address?: string | null
          new_data?: Json | null
          old_data?: Json | null
          performed_by: string
          sale_id: string
          transaction_id: string
          user_agent?: string | null
        }
        Update: {
          action_timestamp?: string
          action_type?: Database["public"]["Enums"]["sale_audit_action"]
          audit_id?: string
          change_details?: string | null
          ip_address?: string | null
          new_data?: Json | null
          old_data?: Json | null
          performed_by?: string
          sale_id?: string
          transaction_id?: string
          user_agent?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "sale_audits_performed_by_fkey"
            columns: ["performed_by"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["user_id"]
          },
          {
            foreignKeyName: "sale_audits_sale_id_fkey"
            columns: ["sale_id"]
            isOneToOne: false
            referencedRelation: "sale_view"
            referencedColumns: ["sale_id"]
          },
          {
            foreignKeyName: "sale_audits_sale_id_fkey"
            columns: ["sale_id"]
            isOneToOne: false
            referencedRelation: "sales"
            referencedColumns: ["sale_id"]
          },
          {
            foreignKeyName: "sale_audits_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "daily_transactions_report"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "sale_audits_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "transactions"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "sale_audits_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "vw_daily_transactions_report_v2"
            referencedColumns: ["transaction_id"]
          },
        ]
      }
      sale_custom_field_definitions: {
        Row: {
          business_id: string
          created_at: string
          default_value: string | null
          field_id: string
          field_name: string
          field_type: Database["public"]["Enums"]["custom_field_type"]
          is_required: boolean
          updated_at: string
          validation_rules: Json | null
        }
        Insert: {
          business_id: string
          created_at?: string
          default_value?: string | null
          field_id?: string
          field_name: string
          field_type: Database["public"]["Enums"]["custom_field_type"]
          is_required?: boolean
          updated_at?: string
          validation_rules?: Json | null
        }
        Update: {
          business_id?: string
          created_at?: string
          default_value?: string | null
          field_id?: string
          field_name?: string
          field_type?: Database["public"]["Enums"]["custom_field_type"]
          is_required?: boolean
          updated_at?: string
          validation_rules?: Json | null
        }
        Relationships: [
          {
            foreignKeyName: "sale_custom_field_definitions_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "sale_custom_field_definitions_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
        ]
      }
      sale_custom_field_values: {
        Row: {
          created_at: string
          field_id: string
          field_value: string | null
          sale_id: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          field_id: string
          field_value?: string | null
          sale_id: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          field_id?: string
          field_value?: string | null
          sale_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "sale_custom_field_values_field_id_fkey"
            columns: ["field_id"]
            isOneToOne: false
            referencedRelation: "sale_custom_field_definitions"
            referencedColumns: ["field_id"]
          },
          {
            foreignKeyName: "sale_custom_field_values_sale_id_fkey"
            columns: ["sale_id"]
            isOneToOne: false
            referencedRelation: "sale_view"
            referencedColumns: ["sale_id"]
          },
          {
            foreignKeyName: "sale_custom_field_values_sale_id_fkey"
            columns: ["sale_id"]
            isOneToOne: false
            referencedRelation: "sales"
            referencedColumns: ["sale_id"]
          },
        ]
      }
      sale_item_subservices: {
        Row: {
          additional_price: number
          created_at: string
          quantity: number
          sale_item_id: string
          sale_item_subservice_id: string
          sub_service_id: string
          total_additional_price: number | null
          updated_at: string
        }
        Insert: {
          additional_price?: number
          created_at?: string
          quantity?: number
          sale_item_id: string
          sale_item_subservice_id?: string
          sub_service_id: string
          total_additional_price?: number | null
          updated_at?: string
        }
        Update: {
          additional_price?: number
          created_at?: string
          quantity?: number
          sale_item_id?: string
          sale_item_subservice_id?: string
          sub_service_id?: string
          total_additional_price?: number | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "sale_item_subservices_sale_item_id_fkey"
            columns: ["sale_item_id"]
            isOneToOne: false
            referencedRelation: "sale_items"
            referencedColumns: ["sale_item_id"]
          },
          {
            foreignKeyName: "sale_item_subservices_sub_service_id_fkey"
            columns: ["sub_service_id"]
            isOneToOne: false
            referencedRelation: "subservices"
            referencedColumns: ["sub_service_id"]
          },
        ]
      }
      sale_items: {
        Row: {
          created_at: string
          item_id: string
          quantity: number
          sale_id: string
          sale_item_id: string
          total_price: number | null
          unit_price: number
          updated_at: string
        }
        Insert: {
          created_at?: string
          item_id: string
          quantity?: number
          sale_id: string
          sale_item_id?: string
          total_price?: number | null
          unit_price?: number
          updated_at?: string
        }
        Update: {
          created_at?: string
          item_id?: string
          quantity?: number
          sale_id?: string
          sale_item_id?: string
          total_price?: number | null
          unit_price?: number
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "sale_items_item_id_fkey"
            columns: ["item_id"]
            isOneToOne: false
            referencedRelation: "items"
            referencedColumns: ["item_id"]
          },
          {
            foreignKeyName: "sale_items_item_id_fkey"
            columns: ["item_id"]
            isOneToOne: false
            referencedRelation: "vw_items"
            referencedColumns: ["item_id"]
          },
          {
            foreignKeyName: "sale_items_sale_id_fkey"
            columns: ["sale_id"]
            isOneToOne: false
            referencedRelation: "sale_view"
            referencedColumns: ["sale_id"]
          },
          {
            foreignKeyName: "sale_items_sale_id_fkey"
            columns: ["sale_id"]
            isOneToOne: false
            referencedRelation: "sales"
            referencedColumns: ["sale_id"]
          },
        ]
      }
      sale_return_items: {
        Row: {
          created_at: string
          quantity: number
          return_id: string
          return_item_id: string
          sale_item_id: string
          total_price: number | null
          unit_price: number
          updated_at: string
        }
        Insert: {
          created_at?: string
          quantity?: number
          return_id: string
          return_item_id?: string
          sale_item_id: string
          total_price?: number | null
          unit_price?: number
          updated_at?: string
        }
        Update: {
          created_at?: string
          quantity?: number
          return_id?: string
          return_item_id?: string
          sale_item_id?: string
          total_price?: number | null
          unit_price?: number
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "sale_return_items_return_id_fkey"
            columns: ["return_id"]
            isOneToOne: false
            referencedRelation: "sale_returns"
            referencedColumns: ["return_id"]
          },
          {
            foreignKeyName: "sale_return_items_return_id_fkey"
            columns: ["return_id"]
            isOneToOne: false
            referencedRelation: "v_sale_returns"
            referencedColumns: ["return_id"]
          },
          {
            foreignKeyName: "sale_return_items_sale_item_id_fkey"
            columns: ["sale_item_id"]
            isOneToOne: false
            referencedRelation: "sale_items"
            referencedColumns: ["sale_item_id"]
          },
        ]
      }
      sale_returns: {
        Row: {
          business_id: string
          created_at: string
          created_by: string
          notes: string | null
          reason: string | null
          return_date: string
          return_id: string
          return_invoice: string
          sale_id: string
          total_amount: number
          transaction_id: string
          updated_at: string
        }
        Insert: {
          business_id: string
          created_at?: string
          created_by?: string
          notes?: string | null
          reason?: string | null
          return_date: string
          return_id?: string
          return_invoice: string
          sale_id: string
          total_amount?: number
          transaction_id: string
          updated_at?: string
        }
        Update: {
          business_id?: string
          created_at?: string
          created_by?: string
          notes?: string | null
          reason?: string | null
          return_date?: string
          return_id?: string
          return_invoice?: string
          sale_id?: string
          total_amount?: number
          transaction_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "sale_returns_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "sale_returns_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "sale_returns_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "employee_view"
            referencedColumns: ["employee_id"]
          },
          {
            foreignKeyName: "sale_returns_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "employees"
            referencedColumns: ["employee_id"]
          },
          {
            foreignKeyName: "sale_returns_sale_id_fkey"
            columns: ["sale_id"]
            isOneToOne: false
            referencedRelation: "sale_view"
            referencedColumns: ["sale_id"]
          },
          {
            foreignKeyName: "sale_returns_sale_id_fkey"
            columns: ["sale_id"]
            isOneToOne: false
            referencedRelation: "sales"
            referencedColumns: ["sale_id"]
          },
          {
            foreignKeyName: "sale_returns_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "daily_transactions_report"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "sale_returns_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "transactions"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "sale_returns_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "vw_daily_transactions_report_v2"
            referencedColumns: ["transaction_id"]
          },
        ]
      }
      sales: {
        Row: {
          attachment_url: string | null
          business_id: string
          created_at: string
          created_by: string
          customer_id: string | null
          discount_amount: number
          due_amount: number
          metadata: Json | null
          notes: string | null
          order_mode: boolean
          paid_amount: number
          platform: string | null
          sale_date: string
          sale_id: string
          sale_invoice: string | null
          shipping_charge: number
          status_id: string
          subtotal: number
          tax_amount: number
          total_amount: number
          transaction_id: string
          updated_at: string
        }
        Insert: {
          attachment_url?: string | null
          business_id: string
          created_at?: string
          created_by?: string
          customer_id?: string | null
          discount_amount?: number
          due_amount?: number
          metadata?: Json | null
          notes?: string | null
          order_mode?: boolean
          paid_amount?: number
          platform?: string | null
          sale_date: string
          sale_id?: string
          sale_invoice?: string | null
          shipping_charge?: number
          status_id: string
          subtotal?: number
          tax_amount?: number
          total_amount?: number
          transaction_id: string
          updated_at?: string
        }
        Update: {
          attachment_url?: string | null
          business_id?: string
          created_at?: string
          created_by?: string
          customer_id?: string | null
          discount_amount?: number
          due_amount?: number
          metadata?: Json | null
          notes?: string | null
          order_mode?: boolean
          paid_amount?: number
          platform?: string | null
          sale_date?: string
          sale_id?: string
          sale_invoice?: string | null
          shipping_charge?: number
          status_id?: string
          subtotal?: number
          tax_amount?: number
          total_amount?: number
          transaction_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "sales_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "sales_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "sales_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["user_id"]
          },
          {
            foreignKeyName: "sales_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "business_customer_view"
            referencedColumns: ["customer_id"]
          },
          {
            foreignKeyName: "sales_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "customer_view"
            referencedColumns: ["customer_id"]
          },
          {
            foreignKeyName: "sales_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "customers"
            referencedColumns: ["customer_id"]
          },
          {
            foreignKeyName: "sales_status_id_fkey"
            columns: ["status_id"]
            isOneToOne: false
            referencedRelation: "statuses"
            referencedColumns: ["status_id"]
          },
          {
            foreignKeyName: "sales_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: true
            referencedRelation: "daily_transactions_report"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "sales_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: true
            referencedRelation: "transactions"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "sales_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: true
            referencedRelation: "vw_daily_transactions_report_v2"
            referencedColumns: ["transaction_id"]
          },
        ]
      }
      states: {
        Row: {
          country_id: number
          id: number
          name: string
        }
        Insert: {
          country_id: number
          id: number
          name: string
        }
        Update: {
          country_id?: number
          id?: number
          name?: string
        }
        Relationships: [
          {
            foreignKeyName: "states_country_id_fkey"
            columns: ["country_id"]
            isOneToOne: false
            referencedRelation: "countries"
            referencedColumns: ["id"]
          },
        ]
      }
      statuses: {
        Row: {
          business_id: string
          created_at: string
          is_default: boolean
          is_editable: boolean
          moving_order: number | null
          name: string
          sequence_order: number
          status_id: string
          type: Database["public"]["Enums"]["status_type"]
          updated_at: string
        }
        Insert: {
          business_id: string
          created_at?: string
          is_default?: boolean
          is_editable?: boolean
          moving_order?: number | null
          name: string
          sequence_order: number
          status_id?: string
          type: Database["public"]["Enums"]["status_type"]
          updated_at?: string
        }
        Update: {
          business_id?: string
          created_at?: string
          is_default?: boolean
          is_editable?: boolean
          moving_order?: number | null
          name?: string
          sequence_order?: number
          status_id?: string
          type?: Database["public"]["Enums"]["status_type"]
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "statuses_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "statuses_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
        ]
      }
      stock_adjustment_items: {
        Row: {
          adjustment_id: string
          adjustment_item_id: string
          created_at: string
          item_id: string
          new_quantity: number
          previous_quantity: number
          quantity_adjusted: number
        }
        Insert: {
          adjustment_id: string
          adjustment_item_id?: string
          created_at?: string
          item_id: string
          new_quantity: number
          previous_quantity: number
          quantity_adjusted: number
        }
        Update: {
          adjustment_id?: string
          adjustment_item_id?: string
          created_at?: string
          item_id?: string
          new_quantity?: number
          previous_quantity?: number
          quantity_adjusted?: number
        }
        Relationships: [
          {
            foreignKeyName: "stock_adjustment_items_adjustment_id_fkey"
            columns: ["adjustment_id"]
            isOneToOne: false
            referencedRelation: "stock_adjustments"
            referencedColumns: ["adjustment_id"]
          },
          {
            foreignKeyName: "stock_adjustment_items_adjustment_id_fkey"
            columns: ["adjustment_id"]
            isOneToOne: false
            referencedRelation: "vw_stock_adjustments"
            referencedColumns: ["adjustment_id"]
          },
          {
            foreignKeyName: "stock_adjustment_items_item_id_fkey"
            columns: ["item_id"]
            isOneToOne: false
            referencedRelation: "items"
            referencedColumns: ["item_id"]
          },
          {
            foreignKeyName: "stock_adjustment_items_item_id_fkey"
            columns: ["item_id"]
            isOneToOne: false
            referencedRelation: "vw_items"
            referencedColumns: ["item_id"]
          },
        ]
      }
      stock_adjustments: {
        Row: {
          adjustment_id: string
          business_id: string
          org_id: string
          performed_at: string
          performed_by: string
          reason: string
          reference: string
          transaction_id: string
        }
        Insert: {
          adjustment_id?: string
          business_id: string
          org_id: string
          performed_at?: string
          performed_by: string
          reason: string
          reference: string
          transaction_id: string
        }
        Update: {
          adjustment_id?: string
          business_id?: string
          org_id?: string
          performed_at?: string
          performed_by?: string
          reason?: string
          reference?: string
          transaction_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "stock_adjustments_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "stock_adjustments_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "stock_adjustments_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "org_details_view"
            referencedColumns: ["org_id"]
          },
          {
            foreignKeyName: "stock_adjustments_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["org_id"]
          },
          {
            foreignKeyName: "stock_adjustments_performed_by_fkey"
            columns: ["performed_by"]
            isOneToOne: false
            referencedRelation: "employee_view"
            referencedColumns: ["employee_id"]
          },
          {
            foreignKeyName: "stock_adjustments_performed_by_fkey"
            columns: ["performed_by"]
            isOneToOne: false
            referencedRelation: "employees"
            referencedColumns: ["employee_id"]
          },
          {
            foreignKeyName: "stock_adjustments_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "daily_transactions_report"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "stock_adjustments_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "transactions"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "stock_adjustments_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "vw_daily_transactions_report_v2"
            referencedColumns: ["transaction_id"]
          },
        ]
      }
      subscription_invoices: {
        Row: {
          amount: number
          amount_due: number | null
          amount_paid: number | null
          created_at: string
          currency: string
          due_date: string | null
          issued_at: string
          line_items: Json | null
          metadata: Json | null
          notes: string | null
          org_id: string
          paid_at: string | null
          payment_provider: string
          payment_provider_invoice_id: string
          payment_provider_order_id: string | null
          payment_provider_payment_id: string | null
          payment_provider_subscription_id: string | null
          payment_url: string | null
          pdf_url: string | null
          status: Database["public"]["Enums"]["invoice_status_enum"]
          subscription_id: string | null
          subscription_invoice_id: string
          updated_at: string
        }
        Insert: {
          amount: number
          amount_due?: number | null
          amount_paid?: number | null
          created_at?: string
          currency: string
          due_date?: string | null
          issued_at: string
          line_items?: Json | null
          metadata?: Json | null
          notes?: string | null
          org_id: string
          paid_at?: string | null
          payment_provider?: string
          payment_provider_invoice_id: string
          payment_provider_order_id?: string | null
          payment_provider_payment_id?: string | null
          payment_provider_subscription_id?: string | null
          payment_url?: string | null
          pdf_url?: string | null
          status?: Database["public"]["Enums"]["invoice_status_enum"]
          subscription_id?: string | null
          subscription_invoice_id?: string
          updated_at?: string
        }
        Update: {
          amount?: number
          amount_due?: number | null
          amount_paid?: number | null
          created_at?: string
          currency?: string
          due_date?: string | null
          issued_at?: string
          line_items?: Json | null
          metadata?: Json | null
          notes?: string | null
          org_id?: string
          paid_at?: string | null
          payment_provider?: string
          payment_provider_invoice_id?: string
          payment_provider_order_id?: string | null
          payment_provider_payment_id?: string | null
          payment_provider_subscription_id?: string | null
          payment_url?: string | null
          pdf_url?: string | null
          status?: Database["public"]["Enums"]["invoice_status_enum"]
          subscription_id?: string | null
          subscription_invoice_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "subscription_invoices_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "org_details_view"
            referencedColumns: ["org_id"]
          },
          {
            foreignKeyName: "subscription_invoices_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["org_id"]
          },
          {
            foreignKeyName: "subscription_invoices_subscription_id_fkey"
            columns: ["subscription_id"]
            isOneToOne: false
            referencedRelation: "subscriptions"
            referencedColumns: ["subscription_id"]
          },
        ]
      }
      subscriptions: {
        Row: {
          addon_id: number | null
          billing_cycle: Database["public"]["Enums"]["billing_cycle_enum"]
          cancel_at_period_end: boolean
          canceled_at: string | null
          created_at: string
          currency: string | null
          current_end: string | null
          current_start: string | null
          end_date: string | null
          metadata: Json | null
          org_id: string
          payment_provider: string | null
          payment_provider_customer_id: string | null
          payment_provider_plan_id: string | null
          payment_provider_subscription_id: string | null
          payment_url: string | null
          plan_amount: number | null
          plan_id: number | null
          quantity: number
          start_date: string | null
          status: Database["public"]["Enums"]["subscription_status_enum"]
          subscription_id: string
          tax_amount: number | null
          total_invoice_amount: number | null
          trial_end_date: string | null
          updated_at: string
        }
        Insert: {
          addon_id?: number | null
          billing_cycle?: Database["public"]["Enums"]["billing_cycle_enum"]
          cancel_at_period_end?: boolean
          canceled_at?: string | null
          created_at?: string
          currency?: string | null
          current_end?: string | null
          current_start?: string | null
          end_date?: string | null
          metadata?: Json | null
          org_id: string
          payment_provider?: string | null
          payment_provider_customer_id?: string | null
          payment_provider_plan_id?: string | null
          payment_provider_subscription_id?: string | null
          payment_url?: string | null
          plan_amount?: number | null
          plan_id?: number | null
          quantity?: number
          start_date?: string | null
          status: Database["public"]["Enums"]["subscription_status_enum"]
          subscription_id?: string
          tax_amount?: number | null
          total_invoice_amount?: number | null
          trial_end_date?: string | null
          updated_at?: string
        }
        Update: {
          addon_id?: number | null
          billing_cycle?: Database["public"]["Enums"]["billing_cycle_enum"]
          cancel_at_period_end?: boolean
          canceled_at?: string | null
          created_at?: string
          currency?: string | null
          current_end?: string | null
          current_start?: string | null
          end_date?: string | null
          metadata?: Json | null
          org_id?: string
          payment_provider?: string | null
          payment_provider_customer_id?: string | null
          payment_provider_plan_id?: string | null
          payment_provider_subscription_id?: string | null
          payment_url?: string | null
          plan_amount?: number | null
          plan_id?: number | null
          quantity?: number
          start_date?: string | null
          status?: Database["public"]["Enums"]["subscription_status_enum"]
          subscription_id?: string
          tax_amount?: number | null
          total_invoice_amount?: number | null
          trial_end_date?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "subscriptions_addon_id_fkey"
            columns: ["addon_id"]
            isOneToOne: false
            referencedRelation: "addons"
            referencedColumns: ["addon_id"]
          },
          {
            foreignKeyName: "subscriptions_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "org_details_view"
            referencedColumns: ["org_id"]
          },
          {
            foreignKeyName: "subscriptions_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["org_id"]
          },
          {
            foreignKeyName: "subscriptions_plan_id_fkey"
            columns: ["plan_id"]
            isOneToOne: false
            referencedRelation: "plans"
            referencedColumns: ["plan_id"]
          },
        ]
      }
      subservices: {
        Row: {
          additional_price: number
          created_at: string
          name: string
          service_id: string
          sub_service_id: string
        }
        Insert: {
          additional_price: number
          created_at?: string
          name: string
          service_id: string
          sub_service_id?: string
        }
        Update: {
          additional_price?: number
          created_at?: string
          name?: string
          service_id?: string
          sub_service_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "subservices_service_id_fkey"
            columns: ["service_id"]
            isOneToOne: false
            referencedRelation: "items"
            referencedColumns: ["item_id"]
          },
          {
            foreignKeyName: "subservices_service_id_fkey"
            columns: ["service_id"]
            isOneToOne: false
            referencedRelation: "vw_items"
            referencedColumns: ["item_id"]
          },
        ]
      }
      suppliers: {
        Row: {
          address: string | null
          business_id: string
          created_at: string
          email: string | null
          gst_number: string | null
          image: string | null
          is_active: boolean
          name: string
          org_id: string
          phone: string
          supplier_balance: number
          supplier_id: string
          updated_at: string | null
        }
        Insert: {
          address?: string | null
          business_id: string
          created_at?: string
          email?: string | null
          gst_number?: string | null
          image?: string | null
          is_active?: boolean
          name: string
          org_id: string
          phone: string
          supplier_balance?: number
          supplier_id?: string
          updated_at?: string | null
        }
        Update: {
          address?: string | null
          business_id?: string
          created_at?: string
          email?: string | null
          gst_number?: string | null
          image?: string | null
          is_active?: boolean
          name?: string
          org_id?: string
          phone?: string
          supplier_balance?: number
          supplier_id?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "suppliers_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "suppliers_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "suppliers_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "org_details_view"
            referencedColumns: ["org_id"]
          },
          {
            foreignKeyName: "suppliers_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["org_id"]
          },
        ]
      }
      taxes: {
        Row: {
          business_id: string
          created_at: string
          name: string
          org_id: string | null
          rate: number
          tax_id: string
          type: string | null
        }
        Insert: {
          business_id: string
          created_at?: string
          name: string
          org_id?: string | null
          rate: number
          tax_id?: string
          type?: string | null
        }
        Update: {
          business_id?: string
          created_at?: string
          name?: string
          org_id?: string | null
          rate?: number
          tax_id?: string
          type?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "taxes_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "taxes_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "taxes_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "org_details_view"
            referencedColumns: ["org_id"]
          },
          {
            foreignKeyName: "taxes_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["org_id"]
          },
        ]
      }
      transaction_entries: {
        Row: {
          account_id: string
          amount: number
          created_at: string
          description: string | null
          entry_id: string
          entry_type: Database["public"]["Enums"]["entry_type"]
          transaction_id: string
        }
        Insert: {
          account_id: string
          amount: number
          created_at?: string
          description?: string | null
          entry_id?: string
          entry_type: Database["public"]["Enums"]["entry_type"]
          transaction_id: string
        }
        Update: {
          account_id?: string
          amount?: number
          created_at?: string
          description?: string | null
          entry_id?: string
          entry_type?: Database["public"]["Enums"]["entry_type"]
          transaction_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "transaction_entries_account_id_fkey"
            columns: ["account_id"]
            isOneToOne: false
            referencedRelation: "accounts"
            referencedColumns: ["account_id"]
          },
          {
            foreignKeyName: "transaction_entries_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "daily_transactions_report"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "transaction_entries_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "transactions"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "transaction_entries_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "vw_daily_transactions_report_v2"
            referencedColumns: ["transaction_id"]
          },
        ]
      }
      transactions: {
        Row: {
          business_id: string
          created_at: string
          created_by: string
          customer_id: string | null
          due_amount: number
          due_date: string | null
          item_id: string | null
          metadata: Json | null
          notes: string | null
          paid_amount: number
          reference_no: string
          reverses_transaction_id: string | null
          status: Database["public"]["Enums"]["transaction_status"]
          supplier_id: string | null
          total_amount: number
          transaction_date: string
          transaction_id: string
          transaction_type: Database["public"]["Enums"]["transaction_type"]
          updated_at: string
        }
        Insert: {
          business_id: string
          created_at?: string
          created_by?: string
          customer_id?: string | null
          due_amount?: number
          due_date?: string | null
          item_id?: string | null
          metadata?: Json | null
          notes?: string | null
          paid_amount?: number
          reference_no: string
          reverses_transaction_id?: string | null
          status?: Database["public"]["Enums"]["transaction_status"]
          supplier_id?: string | null
          total_amount?: number
          transaction_date: string
          transaction_id?: string
          transaction_type: Database["public"]["Enums"]["transaction_type"]
          updated_at?: string
        }
        Update: {
          business_id?: string
          created_at?: string
          created_by?: string
          customer_id?: string | null
          due_amount?: number
          due_date?: string | null
          item_id?: string | null
          metadata?: Json | null
          notes?: string | null
          paid_amount?: number
          reference_no?: string
          reverses_transaction_id?: string | null
          status?: Database["public"]["Enums"]["transaction_status"]
          supplier_id?: string | null
          total_amount?: number
          transaction_date?: string
          transaction_id?: string
          transaction_type?: Database["public"]["Enums"]["transaction_type"]
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "fk_reverses_transaction"
            columns: ["reverses_transaction_id"]
            isOneToOne: false
            referencedRelation: "daily_transactions_report"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "fk_reverses_transaction"
            columns: ["reverses_transaction_id"]
            isOneToOne: false
            referencedRelation: "transactions"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "fk_reverses_transaction"
            columns: ["reverses_transaction_id"]
            isOneToOne: false
            referencedRelation: "vw_daily_transactions_report_v2"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "fk_transactions_item_id"
            columns: ["item_id"]
            isOneToOne: false
            referencedRelation: "items"
            referencedColumns: ["item_id"]
          },
          {
            foreignKeyName: "fk_transactions_item_id"
            columns: ["item_id"]
            isOneToOne: false
            referencedRelation: "vw_items"
            referencedColumns: ["item_id"]
          },
          {
            foreignKeyName: "transactions_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "transactions_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "transactions_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["user_id"]
          },
        ]
      }
      units: {
        Row: {
          business_id: string
          created_at: string
          name: string
          org_id: string | null
          short_name: string | null
          unit_id: string
        }
        Insert: {
          business_id: string
          created_at?: string
          name: string
          org_id?: string | null
          short_name?: string | null
          unit_id?: string
        }
        Update: {
          business_id?: string
          created_at?: string
          name?: string
          org_id?: string | null
          short_name?: string | null
          unit_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "units_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "units_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "units_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "org_details_view"
            referencedColumns: ["org_id"]
          },
          {
            foreignKeyName: "units_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["org_id"]
          },
        ]
      }
      users: {
        Row: {
          created_at: string
          email: string | null
          image: string | null
          name: string
          phone: string | null
          user_id: string
        }
        Insert: {
          created_at?: string
          email?: string | null
          image?: string | null
          name: string
          phone?: string | null
          user_id: string
        }
        Update: {
          created_at?: string
          email?: string | null
          image?: string | null
          name?: string
          phone?: string | null
          user_id?: string
        }
        Relationships: []
      }
      whatsapp_integration: {
        Row: {
          admin_order_assigned_alert: boolean | null
          admin_stock_alert: boolean | null
          business_id: string
          created_at: string | null
          customer_payment_receipt: boolean | null
          customer_sale_invoice: boolean | null
          payment_overdue_alert: string | null
          updated_at: string | null
          whatsapp_integration_id: string
          whatsapp_number_id: string | null
          whatsapp_token: string | null
        }
        Insert: {
          admin_order_assigned_alert?: boolean | null
          admin_stock_alert?: boolean | null
          business_id: string
          created_at?: string | null
          customer_payment_receipt?: boolean | null
          customer_sale_invoice?: boolean | null
          payment_overdue_alert?: string | null
          updated_at?: string | null
          whatsapp_integration_id?: string
          whatsapp_number_id?: string | null
          whatsapp_token?: string | null
        }
        Update: {
          admin_order_assigned_alert?: boolean | null
          admin_stock_alert?: boolean | null
          business_id?: string
          created_at?: string | null
          customer_payment_receipt?: boolean | null
          customer_sale_invoice?: boolean | null
          payment_overdue_alert?: string | null
          updated_at?: string | null
          whatsapp_integration_id?: string
          whatsapp_number_id?: string | null
          whatsapp_token?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "whatsapp_integration_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: true
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "whatsapp_integration_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: true
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
        ]
      }
    }
    Views: {
      business_customer_view: {
        Row: {
          address: string | null
          business_id: string | null
          customer_balance: number | null
          customer_id: string | null
          email: string | null
          image: string | null
          is_active: boolean | null
          name: string | null
          phone: string | null
        }
        Relationships: [
          {
            foreignKeyName: "business_customers_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "business_customers_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "customers_user_id_fkey"
            columns: ["customer_id"]
            isOneToOne: true
            referencedRelation: "users"
            referencedColumns: ["user_id"]
          },
        ]
      }
      customer_view: {
        Row: {
          customer_id: string | null
          email: string | null
          image: string | null
          name: string | null
          phone: string | null
        }
        Relationships: [
          {
            foreignKeyName: "customers_user_id_fkey"
            columns: ["customer_id"]
            isOneToOne: true
            referencedRelation: "users"
            referencedColumns: ["user_id"]
          },
        ]
      }
      daily_transactions_report: {
        Row: {
          balance: number | null
          business_id: string | null
          date: string | null
          name: string | null
          payment_id: string | null
          payment_in: number | null
          payment_method: string | null
          payment_out: number | null
          reference_no: string | null
          total: number | null
          transaction_category: string | null
          transaction_id: string | null
          type: string | null
        }
        Relationships: []
      }
      employee_branches_view: {
        Row: {
          business_id: string | null
          employee_id: string | null
          name: string | null
        }
        Relationships: [
          {
            foreignKeyName: "employee_branch_access_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "employee_branch_access_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "employee_branch_access_employee_id_fkey"
            columns: ["employee_id"]
            isOneToOne: false
            referencedRelation: "employee_view"
            referencedColumns: ["employee_id"]
          },
          {
            foreignKeyName: "employee_branch_access_employee_id_fkey"
            columns: ["employee_id"]
            isOneToOne: false
            referencedRelation: "employees"
            referencedColumns: ["employee_id"]
          },
        ]
      }
      employee_view: {
        Row: {
          business_id: string | null
          business_ids: string[] | null
          code: string | null
          created_at: string | null
          email: string | null
          employee_id: string | null
          employee_role_ids: string[] | null
          employee_roles: Json | null
          image: string | null
          name: string | null
          org_id: string | null
          phone: string | null
          role: Database["public"]["Enums"]["employee_type"] | null
        }
        Relationships: [
          {
            foreignKeyName: "employees_employee_id_fkey"
            columns: ["employee_id"]
            isOneToOne: true
            referencedRelation: "users"
            referencedColumns: ["user_id"]
          },
          {
            foreignKeyName: "employees_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "org_details_view"
            referencedColumns: ["org_id"]
          },
          {
            foreignKeyName: "employees_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["org_id"]
          },
        ]
      }
      expense_view: {
        Row: {
          amount: number | null
          business_id: string | null
          category: Json | null
          created_at: string | null
          date: string | null
          expense_category_id: string | null
          expense_for: string | null
          expense_id: string | null
          note: string | null
          payment_type: Database["public"]["Enums"]["payment_type"] | null
          reference_number: string | null
          status: string | null
          transaction_id: string | null
        }
        Insert: {
          amount?: number | null
          business_id?: string | null
          category?: never
          created_at?: string | null
          date?: string | null
          expense_category_id?: string | null
          expense_for?: string | null
          expense_id?: string | null
          note?: string | null
          payment_type?: Database["public"]["Enums"]["payment_type"] | null
          reference_number?: string | null
          status?: string | null
          transaction_id?: string | null
        }
        Update: {
          amount?: number | null
          business_id?: string | null
          category?: never
          created_at?: string | null
          date?: string | null
          expense_category_id?: string | null
          expense_for?: string | null
          expense_id?: string | null
          note?: string | null
          payment_type?: Database["public"]["Enums"]["payment_type"] | null
          reference_number?: string | null
          status?: string | null
          transaction_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "expenses_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "expenses_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "expenses_expense_category_id_fkey"
            columns: ["expense_category_id"]
            isOneToOne: false
            referencedRelation: "expense_categories"
            referencedColumns: ["category_id"]
          },
          {
            foreignKeyName: "expenses_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "daily_transactions_report"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "expenses_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "transactions"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "expenses_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "vw_daily_transactions_report_v2"
            referencedColumns: ["transaction_id"]
          },
        ]
      }
      income_view: {
        Row: {
          amount: number | null
          business_id: string | null
          category: Json | null
          created_at: string | null
          date: string | null
          income_category_id: string | null
          income_for: string | null
          income_id: string | null
          note: string | null
          payment_type: Database["public"]["Enums"]["payment_type"] | null
          reference_number: string | null
          status: string | null
          transaction_id: string | null
        }
        Insert: {
          amount?: number | null
          business_id?: string | null
          category?: never
          created_at?: string | null
          date?: string | null
          income_category_id?: string | null
          income_for?: string | null
          income_id?: string | null
          note?: string | null
          payment_type?: Database["public"]["Enums"]["payment_type"] | null
          reference_number?: string | null
          status?: string | null
          transaction_id?: string | null
        }
        Update: {
          amount?: number | null
          business_id?: string | null
          category?: never
          created_at?: string | null
          date?: string | null
          income_category_id?: string | null
          income_for?: string | null
          income_id?: string | null
          note?: string | null
          payment_type?: Database["public"]["Enums"]["payment_type"] | null
          reference_number?: string | null
          status?: string | null
          transaction_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "incomes_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "incomes_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "incomes_income_category_id_fkey"
            columns: ["income_category_id"]
            isOneToOne: false
            referencedRelation: "income_categories"
            referencedColumns: ["category_id"]
          },
          {
            foreignKeyName: "incomes_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "daily_transactions_report"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "incomes_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "transactions"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "incomes_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "vw_daily_transactions_report_v2"
            referencedColumns: ["transaction_id"]
          },
        ]
      }
      ledger_parties: {
        Row: {
          amount: number | null
          business_id: string | null
          due_amount: number | null
          id: string | null
          name: string | null
          type: string | null
        }
        Relationships: []
      }
      org_details_view: {
        Row: {
          active_addons_list: Json | null
          active_subscription_details: Json | null
          businesses_list: Json | null
          created_at: string | null
          created_by: string | null
          name: string | null
          org_id: string | null
          trial_activated: boolean | null
        }
        Relationships: [
          {
            foreignKeyName: "organizations_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: true
            referencedRelation: "employee_view"
            referencedColumns: ["employee_id"]
          },
          {
            foreignKeyName: "organizations_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: true
            referencedRelation: "employees"
            referencedColumns: ["employee_id"]
          },
        ]
      }
      purchase_view: {
        Row: {
          attachment_url: string | null
          business_id: string | null
          created_at: string | null
          created_by: string | null
          discount_amount: number | null
          due_amount: number | null
          employee: Json | null
          invoice_no: string | null
          metadata: Json | null
          notes: string | null
          paid_amount: number | null
          payments: Json | null
          purchase_date: string | null
          purchase_id: string | null
          purchase_invoice: string | null
          purchase_items: Json | null
          shipping_charge: number | null
          subtotal: number | null
          supplier: Json | null
          supplier_id: string | null
          tax_amount: number | null
          total_amount: number | null
          transaction: Json | null
          transaction_entries: Json | null
          transaction_id: string | null
          updated_at: string | null
        }
        Relationships: [
          {
            foreignKeyName: "purchases_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "purchases_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "purchases_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "employee_view"
            referencedColumns: ["employee_id"]
          },
          {
            foreignKeyName: "purchases_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "employees"
            referencedColumns: ["employee_id"]
          },
          {
            foreignKeyName: "purchases_supplier_id_fkey"
            columns: ["supplier_id"]
            isOneToOne: false
            referencedRelation: "suppliers"
            referencedColumns: ["supplier_id"]
          },
          {
            foreignKeyName: "purchases_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: true
            referencedRelation: "daily_transactions_report"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "purchases_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: true
            referencedRelation: "transactions"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "purchases_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: true
            referencedRelation: "vw_daily_transactions_report_v2"
            referencedColumns: ["transaction_id"]
          },
        ]
      }
      reseller_referred_businesses: {
        Row: {
          business_id: string | null
          contact_address: string | null
          contact_email: string | null
          contact_phone: string | null
          last_active_at: string | null
          name: string | null
          reseller_id: string | null
          subscription_status:
            | Database["public"]["Enums"]["subscription_status"]
            | null
        }
        Relationships: [
          {
            foreignKeyName: "referrals_reseller_id_fkey"
            columns: ["reseller_id"]
            isOneToOne: false
            referencedRelation: "resellers"
            referencedColumns: ["reseller_id"]
          },
        ]
      }
      sale_view: {
        Row: {
          attachment_url: string | null
          business: Json | null
          business_id: string | null
          created_at: string | null
          created_by: string | null
          customer: Json | null
          customer_id: string | null
          discount_amount: number | null
          due_amount: number | null
          employee: Json | null
          metadata: Json | null
          notes: string | null
          order_mode: boolean | null
          paid_amount: number | null
          payments: Json | null
          platform: string | null
          sale_date: string | null
          sale_id: string | null
          sale_invoice: string | null
          sale_items: Json | null
          shipping_charge: number | null
          status: Json | null
          status_id: string | null
          subtotal: number | null
          tax_amount: number | null
          total_amount: number | null
          transaction: Json | null
          transaction_entries: Json | null
          transaction_id: string | null
          updated_at: string | null
        }
        Relationships: [
          {
            foreignKeyName: "sales_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "sales_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "sales_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["user_id"]
          },
          {
            foreignKeyName: "sales_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "business_customer_view"
            referencedColumns: ["customer_id"]
          },
          {
            foreignKeyName: "sales_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "customer_view"
            referencedColumns: ["customer_id"]
          },
          {
            foreignKeyName: "sales_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "customers"
            referencedColumns: ["customer_id"]
          },
          {
            foreignKeyName: "sales_status_id_fkey"
            columns: ["status_id"]
            isOneToOne: false
            referencedRelation: "statuses"
            referencedColumns: ["status_id"]
          },
          {
            foreignKeyName: "sales_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: true
            referencedRelation: "daily_transactions_report"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "sales_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: true
            referencedRelation: "transactions"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "sales_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: true
            referencedRelation: "vw_daily_transactions_report_v2"
            referencedColumns: ["transaction_id"]
          },
        ]
      }
      sales_purchases_due_report: {
        Row: {
          business_id: string | null
          date: string | null
          due_amount: number | null
          invoice_no: string | null
          party_name: string | null
          payments: Json | null
          total_amount: number | null
          transaction_id: string | null
          transaction_type: string | null
        }
        Relationships: []
      }
      v_purchase_return_items: {
        Row: {
          created_at: string | null
          item_code: string | null
          item_id: string | null
          item_name: string | null
          original_quantity: number | null
          original_total_price: number | null
          original_unit_price: number | null
          purchase_item_id: string | null
          return_id: string | null
          return_item_id: string | null
          return_quantity: number | null
          return_total_price: number | null
          return_unit_price: number | null
          updated_at: string | null
        }
        Relationships: [
          {
            foreignKeyName: "purchase_items_item_id_fkey"
            columns: ["item_id"]
            isOneToOne: false
            referencedRelation: "items"
            referencedColumns: ["item_id"]
          },
          {
            foreignKeyName: "purchase_items_item_id_fkey"
            columns: ["item_id"]
            isOneToOne: false
            referencedRelation: "vw_items"
            referencedColumns: ["item_id"]
          },
          {
            foreignKeyName: "purchase_return_items_purchase_item_id_fkey"
            columns: ["purchase_item_id"]
            isOneToOne: false
            referencedRelation: "purchase_items"
            referencedColumns: ["purchase_item_id"]
          },
          {
            foreignKeyName: "purchase_return_items_return_id_fkey"
            columns: ["return_id"]
            isOneToOne: false
            referencedRelation: "purchase_returns"
            referencedColumns: ["return_id"]
          },
          {
            foreignKeyName: "purchase_return_items_return_id_fkey"
            columns: ["return_id"]
            isOneToOne: false
            referencedRelation: "v_purchase_returns"
            referencedColumns: ["return_id"]
          },
        ]
      }
      v_purchase_returns: {
        Row: {
          accounting_entries: Json | null
          business_id: string | null
          created_at: string | null
          created_by: string | null
          created_by_name: string | null
          notes: string | null
          original_purchase_amount: number | null
          purchase_date: string | null
          purchase_id: string | null
          purchase_invoice: string | null
          reason: string | null
          return_amount: number | null
          return_date: string | null
          return_id: string | null
          return_invoice: string | null
          return_items: Json | null
          supplier: Json | null
          transaction_amount: number | null
          transaction_due_amount: number | null
          transaction_id: string | null
          transaction_paid_amount: number | null
          transaction_reference: string | null
          transaction_status:
            | Database["public"]["Enums"]["transaction_status"]
            | null
          updated_at: string | null
        }
        Relationships: [
          {
            foreignKeyName: "purchase_returns_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "purchase_returns_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "purchase_returns_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "employee_view"
            referencedColumns: ["employee_id"]
          },
          {
            foreignKeyName: "purchase_returns_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "employees"
            referencedColumns: ["employee_id"]
          },
          {
            foreignKeyName: "purchase_returns_purchase_id_fkey"
            columns: ["purchase_id"]
            isOneToOne: false
            referencedRelation: "purchase_view"
            referencedColumns: ["purchase_id"]
          },
          {
            foreignKeyName: "purchase_returns_purchase_id_fkey"
            columns: ["purchase_id"]
            isOneToOne: false
            referencedRelation: "purchases"
            referencedColumns: ["purchase_id"]
          },
          {
            foreignKeyName: "purchase_returns_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "daily_transactions_report"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "purchase_returns_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "transactions"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "purchase_returns_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "vw_daily_transactions_report_v2"
            referencedColumns: ["transaction_id"]
          },
        ]
      }
      v_purchase_returns_summary: {
        Row: {
          business_id: string | null
          return_date: string | null
          returns_list: Json | null
          total_return_amount: number | null
          total_returns: number | null
          unique_suppliers: number | null
        }
        Relationships: [
          {
            foreignKeyName: "purchase_returns_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "purchase_returns_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
        ]
      }
      v_sale_return_items: {
        Row: {
          created_at: string | null
          item_code: string | null
          item_id: string | null
          item_name: string | null
          original_quantity: number | null
          original_total_price: number | null
          original_unit_price: number | null
          return_id: string | null
          return_item_id: string | null
          return_quantity: number | null
          return_total_price: number | null
          return_unit_price: number | null
          sale_item_id: string | null
          updated_at: string | null
        }
        Relationships: [
          {
            foreignKeyName: "sale_items_item_id_fkey"
            columns: ["item_id"]
            isOneToOne: false
            referencedRelation: "items"
            referencedColumns: ["item_id"]
          },
          {
            foreignKeyName: "sale_items_item_id_fkey"
            columns: ["item_id"]
            isOneToOne: false
            referencedRelation: "vw_items"
            referencedColumns: ["item_id"]
          },
          {
            foreignKeyName: "sale_return_items_return_id_fkey"
            columns: ["return_id"]
            isOneToOne: false
            referencedRelation: "sale_returns"
            referencedColumns: ["return_id"]
          },
          {
            foreignKeyName: "sale_return_items_return_id_fkey"
            columns: ["return_id"]
            isOneToOne: false
            referencedRelation: "v_sale_returns"
            referencedColumns: ["return_id"]
          },
          {
            foreignKeyName: "sale_return_items_sale_item_id_fkey"
            columns: ["sale_item_id"]
            isOneToOne: false
            referencedRelation: "sale_items"
            referencedColumns: ["sale_item_id"]
          },
        ]
      }
      v_sale_returns: {
        Row: {
          accounting_entries: Json | null
          business_id: string | null
          created_at: string | null
          created_by: string | null
          created_by_name: string | null
          customer: Json | null
          notes: string | null
          original_sale_amount: number | null
          reason: string | null
          return_amount: number | null
          return_date: string | null
          return_id: string | null
          return_invoice: string | null
          return_items: Json | null
          sale_date: string | null
          sale_id: string | null
          sale_invoice: string | null
          transaction_amount: number | null
          transaction_due_amount: number | null
          transaction_id: string | null
          transaction_paid_amount: number | null
          transaction_reference: string | null
          transaction_status:
            | Database["public"]["Enums"]["transaction_status"]
            | null
          updated_at: string | null
        }
        Relationships: [
          {
            foreignKeyName: "sale_returns_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "sale_returns_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "sale_returns_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "employee_view"
            referencedColumns: ["employee_id"]
          },
          {
            foreignKeyName: "sale_returns_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "employees"
            referencedColumns: ["employee_id"]
          },
          {
            foreignKeyName: "sale_returns_sale_id_fkey"
            columns: ["sale_id"]
            isOneToOne: false
            referencedRelation: "sale_view"
            referencedColumns: ["sale_id"]
          },
          {
            foreignKeyName: "sale_returns_sale_id_fkey"
            columns: ["sale_id"]
            isOneToOne: false
            referencedRelation: "sales"
            referencedColumns: ["sale_id"]
          },
          {
            foreignKeyName: "sale_returns_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "daily_transactions_report"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "sale_returns_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "transactions"
            referencedColumns: ["transaction_id"]
          },
          {
            foreignKeyName: "sale_returns_transaction_id_fkey"
            columns: ["transaction_id"]
            isOneToOne: false
            referencedRelation: "vw_daily_transactions_report_v2"
            referencedColumns: ["transaction_id"]
          },
        ]
      }
      v_sale_returns_summary: {
        Row: {
          business_id: string | null
          return_date: string | null
          returns_list: Json | null
          total_return_amount: number | null
          total_returns: number | null
          unique_customers: number | null
        }
        Relationships: [
          {
            foreignKeyName: "sale_returns_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "sale_returns_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
        ]
      }
      vw_daily_transactions_report_v2: {
        Row: {
          balance: number | null
          business_id: string | null
          date: string | null
          name: string | null
          payment_id: string | null
          payment_in: number | null
          payment_method: string | null
          payment_out: number | null
          reference_no: string | null
          transaction_category: string | null
          transaction_id: string | null
          transaction_total: number | null
          type: string | null
        }
        Relationships: [
          {
            foreignKeyName: "transactions_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "transactions_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
        ]
      }
      vw_items: {
        Row: {
          alert_quantity: number | null
          branch_variant_id: string | null
          brand: Json | null
          business_id: string | null
          created_at: string | null
          custom_fields: Json | null
          has_custom_fields: boolean | null
          images: Json[] | null
          inventory_enabled: boolean | null
          is_active: boolean | null
          is_returnable: boolean | null
          item_category: Json | null
          item_category_id: string | null
          item_code: string | null
          item_id: string | null
          item_type: Database["public"]["Enums"]["item_type"] | null
          name: string | null
          opening_stock_qty: number | null
          opening_stock_value: number | null
          org_id: string | null
          preferred_vendor: Json | null
          purchase_enabled: boolean | null
          purchase_price: number | null
          quantity: number | null
          retail_price: number | null
          rich_text: Json | null
          sale_price: number | null
          sales_enabled: boolean | null
          serial_nos: string[] | null
          stock_quantity: number | null
          stock_status: string | null
          stock_value: number | null
          sub_services: Json | null
          tax: Json | null
          unit: Json | null
        }
        Relationships: [
          {
            foreignKeyName: "items_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "items_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "items_item_category_id_fkey"
            columns: ["item_category_id"]
            isOneToOne: false
            referencedRelation: "item_categories"
            referencedColumns: ["item_category_id"]
          },
          {
            foreignKeyName: "items_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "org_details_view"
            referencedColumns: ["org_id"]
          },
          {
            foreignKeyName: "items_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["org_id"]
          },
        ]
      }
      vw_stock_adjustments: {
        Row: {
          adjusted_items: Json | null
          adjustment_id: string | null
          business_id: string | null
          org_id: string | null
          performed_at: string | null
          performed_by: string | null
          performed_user: string | null
          reason: string | null
          reference: string | null
        }
        Relationships: [
          {
            foreignKeyName: "stock_adjustments_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "stock_adjustments_business_id_fkey"
            columns: ["business_id"]
            isOneToOne: false
            referencedRelation: "reseller_referred_businesses"
            referencedColumns: ["business_id"]
          },
          {
            foreignKeyName: "stock_adjustments_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "org_details_view"
            referencedColumns: ["org_id"]
          },
          {
            foreignKeyName: "stock_adjustments_org_id_fkey"
            columns: ["org_id"]
            isOneToOne: false
            referencedRelation: "organizations"
            referencedColumns: ["org_id"]
          },
          {
            foreignKeyName: "stock_adjustments_performed_by_fkey"
            columns: ["performed_by"]
            isOneToOne: false
            referencedRelation: "employee_view"
            referencedColumns: ["employee_id"]
          },
          {
            foreignKeyName: "stock_adjustments_performed_by_fkey"
            columns: ["performed_by"]
            isOneToOne: false
            referencedRelation: "employees"
            referencedColumns: ["employee_id"]
          },
        ]
      }
    }
    Functions: {
      adjust_stock: {
        Args: {
          p_adjustment_json: Json
          p_business_id: string
          p_org_id: string
        }
        Returns: string
      }
      archive_customer: {
        Args: {
          p_customer_id: string
          p_business_id: string
        }
        Returns: undefined
      }
      archive_item: {
        Args: {
          p_item_id: string
          p_business_id: string
        }
        Returns: undefined
      }
      archive_supplier: {
        Args: {
          p_supplier_id: string
        }
        Returns: undefined
      }
      build_account_node: {
        Args: {
          _account_id: string
          _business_id: string
        }
        Returns: Json
      }
      bulk_import_items: {
        Args: {
          p_import_data: Json
        }
        Returns: Json
      }
      cancel_expired_trials: {
        Args: Record<PropertyKey, never>
        Returns: undefined
      }
      check_user_exists: {
        Args: {
          p_email?: string
          p_phone?: string
        }
        Returns: {
          aud: string | null
          banned_until: string | null
          confirmation_sent_at: string | null
          confirmation_token: string | null
          confirmed_at: string | null
          created_at: string | null
          deleted_at: string | null
          email: string | null
          email_change: string | null
          email_change_confirm_status: number | null
          email_change_sent_at: string | null
          email_change_token_current: string | null
          email_change_token_new: string | null
          email_confirmed_at: string | null
          encrypted_password: string | null
          id: string
          instance_id: string | null
          invited_at: string | null
          is_anonymous: boolean
          is_sso_user: boolean
          is_super_admin: boolean | null
          last_sign_in_at: string | null
          phone: string | null
          phone_change: string | null
          phone_change_sent_at: string | null
          phone_change_token: string | null
          phone_confirmed_at: string | null
          raw_app_meta_data: Json | null
          raw_user_meta_data: Json | null
          reauthentication_sent_at: string | null
          reauthentication_token: string | null
          recovery_sent_at: string | null
          recovery_token: string | null
          role: string | null
          updated_at: string | null
        }[]
      }
      clear_sequences: {
        Args: {
          business_id: string
        }
        Returns: undefined
      }
      create_addon_subscription_package: {
        Args: {
          p_org_id: string
          p_addon_id: number
          p_payment_provider_subscription_id: string
          p_initial_status: Database["public"]["Enums"]["subscription_status_enum"]
          p_start_date: string
          p_payment_provider: string
          p_payment_provider_item_id: string
          p_end_date: string
          p_invoices: Json
          p_payment_url: string
          p_metadata: Json
          p_quantity: number
          p_billing_cycle: Database["public"]["Enums"]["billing_cycle_enum"]
          p_country_code: string
          p_currency_code: string
          p_trial_end_date?: string
          p_current_start?: string
          p_current_end?: string
        }
        Returns: string
      }
      create_default_chart_of_accounts: {
        Args: {
          p_business_id: string
          p_org_id: string
        }
        Returns: undefined
      }
      create_paid_subscription_package: {
        Args: {
          p_org_id: string
          p_plan_id: number
          p_payment_provider_subscription_id: string
          p_initial_status: Database["public"]["Enums"]["subscription_status_enum"]
          p_start_date: string
          p_payment_provider: string
          p_payment_provider_plan_id: string
          p_end_date: string
          p_trial_end_date: string
          p_invoices: Json
          p_payment_url: string
          p_metadata: Json
          p_billing_cycle: Database["public"]["Enums"]["billing_cycle_enum"]
          p_current_start?: string
          p_current_end?: string
        }
        Returns: string
      }
      create_purchase: {
        Args: {
          p_purchase_json: Json
        }
        Returns: Json
      }
      create_purchase_return: {
        Args: {
          p_data: Json
        }
        Returns: string
      }
      create_sale: {
        Args: {
          p_sale_json: Json
        }
        Returns: Json
      }
      create_sale_return: {
        Args: {
          p_data: Json
        }
        Returns: string
      }
      create_sequences: {
        Args: {
          business_id: string
        }
        Returns: undefined
      }
      generate_business_dependencies: {
        Args: {
          business_data: Json
        }
        Returns: string
      }
      get_business_summaries:
        | {
            Args: {
              p_business_id: string
            }
            Returns: Json
          }
        | {
            Args: {
              p_business_id: string
              p_org_id: string
            }
            Returns: Json
          }
      get_chart_of_accounts_tree: {
        Args: {
          p_business_id: string
        }
        Returns: Json
      }
      get_current_fiscal_period: {
        Args: {
          p_business_id: string
        }
        Returns: Json
      }
      get_dashboard_data: {
        Args: {
          p_business_id: string
        }
        Returns: Json
      }
      get_employee_sales_report: {
        Args: {
          start_date?: string
          end_date?: string
          page_number?: number
          page_size?: number
          p_business_id?: string
          employee_name_filter?: string
        }
        Returns: {
          employee_name: string
          employee_role: Database["public"]["Enums"]["employee_type"]
          employee_code: string
          total_items_sold: number
          total_revenue_generated: number
        }[]
      }
      get_my_claim: {
        Args: {
          claim: string
        }
        Returns: Json
      }
      get_my_current_org_id: {
        Args: Record<PropertyKey, never>
        Returns: string
      }
      get_my_user_type: {
        Args: Record<PropertyKey, never>
        Returns: string
      }
      get_next_item_code: {
        Args: {
          business_id: string
        }
        Returns: string
      }
      get_next_purchase_code: {
        Args: {
          business_id: string
        }
        Returns: string
      }
      get_next_purchase_return_code: {
        Args: {
          business_id: string
        }
        Returns: string
      }
      get_next_sale_code: {
        Args: {
          business_id: string
        }
        Returns: string
      }
      get_next_sale_return_code: {
        Args: {
          business_id: string
        }
        Returns: string
      }
      get_or_create_brand: {
        Args: {
          p_business_id: string
          p_brand_name: string
        }
        Returns: string
      }
      get_or_create_item_category: {
        Args: {
          p_business_id: string
          p_category_name: string
        }
        Returns: string
      }
      get_or_create_unit: {
        Args: {
          p_business_id: string
          p_unit_name: string
          p_unit_short_name?: string
        }
        Returns: string
      }
      get_party_transaction_summary: {
        Args: {
          party_type: string
          party_id: string
        }
        Returns: Json
      }
      get_profit_and_loss:
        | {
            Args: {
              p_business_id: string
              p_org_id: string
              p_start_date: string
              p_end_date: string
            }
            Returns: Json
          }
        | {
            Args: {
              p_business_id: string
              p_start_date: string
              p_end_date: string
            }
            Returns: Json
          }
      get_promotional_addon_details: {
        Args: {
          p_country_code: string
        }
        Returns: Json
      }
      get_promotional_plan_details: {
        Args: {
          p_country_code: string
        }
        Returns: Json
      }
      get_purchase_summary:
        | {
            Args: {
              p_business_id: string
              p_org_id: string
              p_start_date?: string
              p_end_date?: string
            }
            Returns: Json
          }
        | {
            Args: {
              p_business_id: string
              p_start_date?: string
              p_end_date?: string
            }
            Returns: Json
          }
      get_role_permissions: {
        Args: {
          role_id?: string
        }
        Returns: Json
      }
      get_sales_summary:
        | {
            Args: {
              p_business_id: string
              p_org_id: string
              p_start_date?: string
              p_end_date?: string
            }
            Returns: Json
          }
        | {
            Args: {
              p_business_id: string
              p_start_date?: string
              p_end_date?: string
            }
            Returns: Json
          }
      get_sidebar: {
        Args: Record<PropertyKey, never>
        Returns: Json
      }
      get_total_dues_summary:
        | {
            Args: {
              p_business_id: string
              p_org_id: string
              p_start_date?: string
              p_end_date?: string
            }
            Returns: Json
          }
        | {
            Args: {
              p_business_id: string
              p_start_date?: string
              p_end_date?: string
            }
            Returns: Json
          }
      handle_free_plan_switch: {
        Args: {
          p_org_id: string
          p_start_date: string
        }
        Returns: undefined
      }
      is_employee_of_any_org: {
        Args: {
          p_user_id: string
        }
        Returns: boolean
      }
      is_employee_of_org: {
        Args: {
          p_user_id: string
          p_org_id: string
        }
        Returns: boolean
      }
      register_business: {
        Args: {
          business_data: Json
        }
        Returns: undefined
      }
      reverse_stock_adjustment: {
        Args: {
          p_original_adjustment_id: string
          p_reversal_date?: string
          p_reason?: string
        }
        Returns: string
      }
      reverse_transaction: {
        Args: {
          p_original_transaction_id: string
          p_reversal_date?: string
          p_reason?: string
        }
        Returns: string
      }
      settle_purchase_payment:
        | {
            Args: {
              p_purchase_id: string
              p_amount: number
              p_payment_mode: string
              p_payment_date: string
            }
            Returns: string
          }
        | {
            Args: {
              p_purchase_id: string
              p_org_id: string
              p_amount: number
              p_payment_mode: string
              p_payment_date: string
            }
            Returns: string
          }
      settle_sale_payment:
        | {
            Args: {
              p_sale_id: string
              p_amount: number
              p_payment_mode: string
              p_payment_date: string
            }
            Returns: string
          }
        | {
            Args: {
              p_sale_id: string
              p_org_id: string
              p_amount: number
              p_payment_mode: string
              p_payment_date: string
            }
            Returns: string
          }
      update_sale: {
        Args: {
          p_sale_json: Json
        }
        Returns: Json
      }
      upsert_business_customer: {
        Args: {
          p_customer_data: Json
        }
        Returns: undefined
      }
      upsert_employee_role: {
        Args: {
          employee_role_json: Json
        }
        Returns: undefined
      }
      upsert_expense: {
        Args: {
          p_expense_data: Json
        }
        Returns: string
      }
      upsert_income: {
        Args: {
          p_income_data: Json
        }
        Returns: string
      }
      upsert_item: {
        Args: {
          item_json: Json
        }
        Returns: string
      }
      upsert_supplier: {
        Args: {
          p_supplier_data: Json
        }
        Returns: string
      }
      verify_transaction_balance: {
        Args: {
          p_transaction_id: string
        }
        Returns: undefined
      }
      verify_user_password: {
        Args: {
          password: string
        }
        Returns: boolean
      }
    }
    Enums: {
      addon_type_enum: "limit_increase" | "feature_enable" | "metered_quota"
      billing_cycle_enum: "monthly" | "annually"
      business_types: "retail" | "automotive" | "foodAndBeverage" | "others"
      custom_field_type: "text"
      employee_type: "admin" | "staff" | "customer"
      entry_type: "CREDIT" | "DEBIT"
      feature_type_enum: "boolean" | "limit" | "metered"
      invoice_status_enum:
        | "draft"
        | "issued"
        | "paid"
        | "void"
        | "partially_paid"
        | "pending"
      item_type: "goods" | "services"
      payment_type: "cash" | "card" | "bank"
      purchase_audit_action:
        | "CREATED"
        | "UPDATED"
        | "PAYMENT_ADDED"
        | "STATUS_CHANGED"
        | "CANCELED"
        | "ITEM_ADDED"
        | "ITEM_REMOVED"
        | "ITEM_QUANTITY_CHANGED"
        | "RETURN_CREATED"
      sale_audit_action:
        | "CREATED"
        | "UPDATED"
        | "PAYMENT_ADDED"
        | "STATUS_CHANGED"
        | "CANCELED"
        | "ITEM_ADDED"
        | "ITEM_REMOVED"
        | "ITEM_QUANTITY_CHANGED"
        | "RETURN_CREATED"
        | "DISCOUNT_APPLIED"
        | "DELIVERY_STATUS_CHANGED"
        | "INVOICE_GENERATED"
      status_type: "sale"
      subscription_status: "active" | "inactive" | "expired" | "cancelled"
      subscription_status_enum:
        | "trialing"
        | "active"
        | "past_due"
        | "canceled"
        | "ended"
        | "free_limited"
        | "paused"
        | "pending_activation"
      transaction_status:
        | "PENDING"
        | "PARTIALLY_PAID"
        | "PAID"
        | "VOID"
        | "CANCELLED"
        | "REVERSED"
      transaction_type:
        | "SALE"
        | "PURCHASE"
        | "SALE_RETURN"
        | "PURCHASE_RETURN"
        | "INCOME"
        | "EXPENSE"
        | "ADJUSTMENT"
        | "OPENING_STOCK"
        | "SUPPLIER_OPENING_BALANCE"
        | "STOCK_ADJUSTMENT"
        | "CUSTOMER_OPENING_BALANCE"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type PublicSchema = Database[Extract<keyof Database, "public">]

export type Tables<
  PublicTableNameOrOptions extends
    | keyof (PublicSchema["Tables"] & PublicSchema["Views"])
    | { schema: keyof Database },
  TableName extends PublicTableNameOrOptions extends { schema: keyof Database }
    ? keyof (Database[PublicTableNameOrOptions["schema"]]["Tables"] &
        Database[PublicTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = PublicTableNameOrOptions extends { schema: keyof Database }
  ? (Database[PublicTableNameOrOptions["schema"]]["Tables"] &
      Database[PublicTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : PublicTableNameOrOptions extends keyof (PublicSchema["Tables"] &
        PublicSchema["Views"])
    ? (PublicSchema["Tables"] &
        PublicSchema["Views"])[PublicTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  PublicTableNameOrOptions extends
    | keyof PublicSchema["Tables"]
    | { schema: keyof Database },
  TableName extends PublicTableNameOrOptions extends { schema: keyof Database }
    ? keyof Database[PublicTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = PublicTableNameOrOptions extends { schema: keyof Database }
  ? Database[PublicTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : PublicTableNameOrOptions extends keyof PublicSchema["Tables"]
    ? PublicSchema["Tables"][PublicTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  PublicTableNameOrOptions extends
    | keyof PublicSchema["Tables"]
    | { schema: keyof Database },
  TableName extends PublicTableNameOrOptions extends { schema: keyof Database }
    ? keyof Database[PublicTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = PublicTableNameOrOptions extends { schema: keyof Database }
  ? Database[PublicTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : PublicTableNameOrOptions extends keyof PublicSchema["Tables"]
    ? PublicSchema["Tables"][PublicTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  PublicEnumNameOrOptions extends
    | keyof PublicSchema["Enums"]
    | { schema: keyof Database },
  EnumName extends PublicEnumNameOrOptions extends { schema: keyof Database }
    ? keyof Database[PublicEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = PublicEnumNameOrOptions extends { schema: keyof Database }
  ? Database[PublicEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : PublicEnumNameOrOptions extends keyof PublicSchema["Enums"]
    ? PublicSchema["Enums"][PublicEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof PublicSchema["CompositeTypes"]
    | { schema: keyof Database },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof Database
  }
    ? keyof Database[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends { schema: keyof Database }
  ? Database[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof PublicSchema["CompositeTypes"]
    ? PublicSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

