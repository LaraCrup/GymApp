
export type Json = string | number | boolean | null | { [key: string]: Json | undefined } | Json[]

export type Database = {
  
  "graphql_public": {
          Tables: {
            [_ in never]: never
          }
          Views: {
            [_ in never]: never
          }
          Functions: {
            "graphql":
{ Args: { "extensions"?: Json,"operationName"?: string,"query"?: string,"variables"?: Json }; Returns: Json
                           }
          }
          Enums: {
            [_ in never]: never
          }
          CompositeTypes: {
            [_ in never]: never
          }
        },"public": {
          Tables: {
            "exercises": {
                  Row: {
                    "aliases": (string)[],"created_at": string,"created_by": string | null,"id": string,"muscle_group_id": string,"name": string,"search_text": string,"updated_at": string,"youtube_id": string | null
                  }
                  Insert: {
                    "aliases"?: (string)[],"created_at"?: string,"created_by"?: string | null,"id"?: string,"muscle_group_id": string,"name": string,"search_text"?: string,"updated_at"?: string,"youtube_id"?: string | null
                  }
                  Update: {
                    "aliases"?: (string)[],"created_at"?: string,"created_by"?: string | null,"id"?: string,"muscle_group_id"?: string,"name"?: string,"search_text"?: string,"updated_at"?: string,"youtube_id"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "exercises_muscle_group_id_fkey"
      columns: ["muscle_group_id"]
isOneToOne: false
      referencedRelation: "muscle_groups"
      referencedColumns: ["id"]
    }
                  ]
                },"muscle_groups": {
                  Row: {
                    "id": string,"name": string,"sort_order": number
                  }
                  Insert: {
                    "id": string,"name": string,"sort_order": number
                  }
                  Update: {
                    "id"?: string,"name"?: string,"sort_order"?: number
                  }
                  Relationships: [
                    
                  ]
                },"routine_exercises": {
                  Row: {
                    "created_at": string,"exercise_id": string,"id": string,"position": number,"reps": number,"routine_id": string,"sets": number,"updated_at": string,"user_id": string,"weight_kg": number
                  }
                  Insert: {
                    "created_at"?: string,"exercise_id": string,"id"?: string,"position"?: number,"reps"?: number,"routine_id": string,"sets"?: number,"updated_at"?: string,"user_id"?: string,"weight_kg"?: number
                  }
                  Update: {
                    "created_at"?: string,"exercise_id"?: string,"id"?: string,"position"?: number,"reps"?: number,"routine_id"?: string,"sets"?: number,"updated_at"?: string,"user_id"?: string,"weight_kg"?: number
                  }
                  Relationships: [
                    {
      foreignKeyName: "routine_exercises_exercise_id_fkey"
      columns: ["exercise_id"]
isOneToOne: false
      referencedRelation: "exercises"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "routine_exercises_routine_id_fkey"
      columns: ["routine_id"]
isOneToOne: false
      referencedRelation: "routines"
      referencedColumns: ["id"]
    }
                  ]
                },"routines": {
                  Row: {
                    "created_at": string,"id": string,"name": string,"updated_at": string,"user_id": string
                  }
                  Insert: {
                    "created_at"?: string,"id"?: string,"name": string,"updated_at"?: string,"user_id"?: string
                  }
                  Update: {
                    "created_at"?: string,"id"?: string,"name"?: string,"updated_at"?: string,"user_id"?: string
                  }
                  Relationships: [
                    
                  ]
                },"weight_logs": {
                  Row: {
                    "exercise_id": string,"id": number,"logged_on": string,"routine_exercise_id": string | null,"updated_at": string,"user_id": string,"weight_kg": number
                  }
                  Insert: {
                    "exercise_id": string,"id"?: never,"logged_on": string,"routine_exercise_id"?: string | null,"updated_at"?: string,"user_id": string,"weight_kg": number
                  }
                  Update: {
                    "exercise_id"?: string,"id"?: never,"logged_on"?: string,"routine_exercise_id"?: string | null,"updated_at"?: string,"user_id"?: string,"weight_kg"?: number
                  }
                  Relationships: [
                    {
      foreignKeyName: "weight_logs_exercise_id_fkey"
      columns: ["exercise_id"]
isOneToOne: false
      referencedRelation: "exercises"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "weight_logs_routine_exercise_id_fkey"
      columns: ["routine_exercise_id"]
isOneToOne: false
      referencedRelation: "routine_exercises"
      referencedColumns: ["id"]
    }
                  ]
                }
          }
          Views: {
            [_ in never]: never
          }
          Functions: {
            "is_admin":
{ Args: Record<PropertyKey, never>; Returns: boolean
                           },
"normalize_text":
{ Args: { "t": string }; Returns: string
                           },
"previous_weights":
{ Args: { "p_exercise_ids": (string)[] }; Returns: {
              "exercise_id": string,"logged_on": string,"weight_kg": number
            }[]
                           },
"reorder_routine_exercises":
{ Args: { "p_ids": (string)[],"p_routine_id": string }; Returns: undefined
                           },
"search_exercises":
{ Args: { "group_id"?: string,"max_results"?: number,"q"?: string }; Returns: {
              "aliases": (string)[],
"created_at": string,
"created_by": string | null,
"id": string,
"muscle_group_id": string,
"name": string,
"search_text": string,
"updated_at": string,
"youtube_id": string | null
            }[]
                          SetofOptions: {
        from: "*"
        to: "exercises"
        isOneToOne: false
        isSetofReturn: true
      } },
"similar_exercises":
{ Args: { "aliases"?: (string)[],"name": string }; Returns: {
              "aliases": (string)[],"id": string,"muscle_group_id": string,"name": string,"score": number,"youtube_id": string
            }[]
                           }
          }
          Enums: {
            [_ in never]: never
          }
          CompositeTypes: {
            [_ in never]: never
          }
        }
}

type DatabaseWithoutInternals = Omit<Database, '__InternalSupabase'>

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never
> = DefaultSchemaTableNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
  ? (DefaultSchema["Tables"] & DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
      Row: infer R
    }
    ? R
    : never
  : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never
> = DefaultSchemaTableNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
  ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
      Insert: infer I
    }
    ? I
    : never
  : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never
> = DefaultSchemaTableNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
  ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
      Update: infer U
    }
    ? U
    : never
  : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never
> = DefaultSchemaEnumNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
  ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
  : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never
> = PublicCompositeTypeNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
  ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
  : never

export const Constants = {
  "graphql_public": {
          Enums: {
            
          }
        },"public": {
          Enums: {
            
          }
        }
} as const

