-- Backfill da biblioteca de fotos. Executado na main em 2026-11-14, depois do deploy request 50.
-- Resultado: 46 fotos, 0 duplicadas, 0 legacy, 35 image, 1 service, 9 amenity, 1 email.
-- Pre-requisito: tabela `venue_photo` e colunas `photoId` / `backgroundPhotoId` na `main`.
-- Idempotente: nao reinsere `(venueId, url)` existente e so preenche `photoId` nulo.
-- Sem DELETE e sem DROP. Imagem so de organizacao (`image.venueId` nulo) fica de fora.
-- URL com mais de 1024 caracteres fica de fora e aparece no relatorio.

INSERT INTO `venue_photo` (`id`, `venueId`, `url`, `storageKey`, `createdAt`, `updatedAt`)
SELECT
    REPLACE(UUID(), '-', ''),
    ready.venueId,
    ready.url,
    ready.storageKey,
    CURRENT_TIMESTAMP(3),
    CURRENT_TIMESTAMP(3)
FROM (
    SELECT
        src.venueId,
        src.url,
        CASE
            WHEN src.url LIKE '%amazonaws.com/%' THEN LEFT(
                SUBSTRING(src.url, LOCATE('amazonaws.com/', src.url) + CHAR_LENGTH('amazonaws.com/')),
                512
            )
            ELSE CONCAT('legacy:', LEFT(src.url, 500))
        END AS storageKey
    FROM (
        SELECT DISTINCT raw.venueId, raw.url
        FROM (
            SELECT `venueId` AS venueId, `imageUrl` AS url
            FROM `image`
            WHERE `venueId` IS NOT NULL
              AND `imageUrl` IS NOT NULL
              AND CHAR_LENGTH(`imageUrl`) BETWEEN 1 AND 1024
            UNION
            SELECT `venueId`, `imageUrl`
            FROM `service`
            WHERE `imageUrl` IS NOT NULL
              AND CHAR_LENGTH(`imageUrl`) BETWEEN 1 AND 1024
            UNION
            SELECT va.`venueId`, vai.`imageUrl`
            FROM `venue_amenity_image` vai
            INNER JOIN `venue_amenity` va ON va.`id` = vai.`amenityId`
            WHERE vai.`imageUrl` IS NOT NULL
              AND CHAR_LENGTH(vai.`imageUrl`) BETWEEN 1 AND 1024
            UNION
            SELECT `venueId`, `backgroundImageUrl`
            FROM `emailConfig`
            WHERE `backgroundImageUrl` IS NOT NULL
              AND CHAR_LENGTH(`backgroundImageUrl`) BETWEEN 1 AND 1024
        ) raw
    ) src
    LEFT JOIN `venue_photo` existing
        ON existing.`venueId` = src.venueId
       AND existing.`url` = src.url
    WHERE existing.`id` IS NULL
) ready;

UPDATE `image` i
INNER JOIN `venue_photo` vp ON vp.`venueId` = i.`venueId` AND vp.`url` = i.`imageUrl`
SET i.`photoId` = vp.`id`
WHERE i.`venueId` IS NOT NULL
  AND i.`photoId` IS NULL
  AND i.`imageUrl` IS NOT NULL
  AND CHAR_LENGTH(i.`imageUrl`) BETWEEN 1 AND 1024;

UPDATE `service` s
INNER JOIN `venue_photo` vp ON vp.`venueId` = s.`venueId` AND vp.`url` = s.`imageUrl`
SET s.`photoId` = vp.`id`
WHERE s.`photoId` IS NULL
  AND s.`imageUrl` IS NOT NULL
  AND CHAR_LENGTH(s.`imageUrl`) BETWEEN 1 AND 1024;

UPDATE `venue_amenity_image` vai
INNER JOIN `venue_amenity` va ON va.`id` = vai.`amenityId`
INNER JOIN `venue_photo` vp ON vp.`venueId` = va.`venueId` AND vp.`url` = vai.`imageUrl`
SET vai.`photoId` = vp.`id`
WHERE vai.`photoId` IS NULL
  AND vai.`imageUrl` IS NOT NULL
  AND CHAR_LENGTH(vai.`imageUrl`) BETWEEN 1 AND 1024;

UPDATE `emailConfig` e
INNER JOIN `venue_photo` vp ON vp.`venueId` = e.`venueId` AND vp.`url` = e.`backgroundImageUrl`
SET e.`backgroundPhotoId` = vp.`id`
WHERE e.`backgroundPhotoId` IS NULL
  AND e.`backgroundImageUrl` IS NOT NULL
  AND CHAR_LENGTH(e.`backgroundImageUrl`) BETWEEN 1 AND 1024;

-- Relatorio (somente leitura), depois da escrita aprovada:
-- SELECT COUNT(*) AS fotos FROM venue_photo;
-- SELECT venueId, url FROM venue_photo WHERE storageKey LIKE 'legacy:%';
-- SELECT COUNT(*) AS imagens_so_organizacao FROM image WHERE venueId IS NULL AND imageUrl IS NOT NULL AND CHAR_LENGTH(imageUrl) > 0;
-- SELECT COUNT(*) AS urls_longas_demais FROM (
--   SELECT imageUrl AS url FROM image WHERE venueId IS NOT NULL AND CHAR_LENGTH(imageUrl) > 1024
--   UNION ALL SELECT imageUrl FROM service WHERE CHAR_LENGTH(imageUrl) > 1024
--   UNION ALL SELECT vai.imageUrl FROM venue_amenity_image vai WHERE CHAR_LENGTH(vai.imageUrl) > 1024
--   UNION ALL SELECT backgroundImageUrl FROM emailConfig WHERE CHAR_LENGTH(backgroundImageUrl) > 1024
-- ) long_urls;
-- SELECT COUNT(*) AS image_sem_photo FROM image WHERE venueId IS NOT NULL AND photoId IS NULL AND CHAR_LENGTH(imageUrl) BETWEEN 1 AND 1024;
-- SELECT COUNT(*) AS service_sem_photo FROM service WHERE photoId IS NULL AND CHAR_LENGTH(imageUrl) BETWEEN 1 AND 1024;
-- SELECT COUNT(*) AS amenity_sem_photo FROM venue_amenity_image WHERE photoId IS NULL AND CHAR_LENGTH(imageUrl) BETWEEN 1 AND 1024;
-- SELECT COUNT(*) AS email_sem_photo FROM emailConfig WHERE backgroundPhotoId IS NULL AND CHAR_LENGTH(backgroundImageUrl) BETWEEN 1 AND 1024;
