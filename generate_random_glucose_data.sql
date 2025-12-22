-- ============================================
-- Script untuk Generate Data Glukosa Random (90 Hari)
-- ============================================

DO $$
DECLARE
    -- GANTI 'YOUR_USER_ID_HERE' DI BAWAH INI DENGAN ID USER ANDA YANG SEBENARNYA!
    target_user_id TEXT := '5123b63c-14a4-42ed-b8b5-0e576f058ad1'; 
    
    record_time TIMESTAMP; -- Mengganti nama variable agar tidak bentrok dengan keyword
    glucose_value FLOAT;
    days_ago INT;
    hour_time INT;
BEGIN
    -- Loop untuk 90 hari terakhir
    FOR days_ago IN 0..89 LOOP
        
        -- 1. DATA PAGI (Before Meal) - Jam 07:00 - 09:00
        record_time := NOW() - (days_ago || ' days')::INTERVAL 
                       + ((7 + floor(random() * 2)) || ' hours')::INTERVAL;
        
        -- Nilai acak 70-120 mg/dL
        glucose_value := 70 + (random() * 50);
        
        INSERT INTO glucose_records (
            id, user_id, glucose_level, timestamp, condition, is_from_iot, created_at, updated_at
        ) VALUES (
            gen_random_uuid()::TEXT,
            target_user_id,
            glucose_value,
            record_time,
            'beforeMeal',
            false,
            NOW(),
            NOW()
        );
        
        -- 2. DATA SIANG/MALAM (After Meal) - Jam 13-15 atau 19-21
        hour_time := CASE 
            WHEN random() > 0.5 THEN 13 + floor(random() * 2)  -- Siang
            ELSE 19 + floor(random() * 2)  -- Malam
        END;
        
        record_time := NOW() - (days_ago || ' days')::INTERVAL 
                       + (hour_time || ' hours')::INTERVAL;
        
        -- Nilai acak 100-180 mg/dL
        glucose_value := 100 + (random() * 80);
        
        INSERT INTO glucose_records (
            id, user_id, glucose_level, timestamp, condition, is_from_iot, created_at, updated_at
        ) VALUES (
            gen_random_uuid()::TEXT,
            target_user_id,
            glucose_value,
            record_time,
            'afterMeal',
            false,
            NOW(),
            NOW()
        );
        
    END LOOP;
    
    RAISE NOTICE 'Berhasil menambahkan 180 data random untuk user %', target_user_id;
END $$;
