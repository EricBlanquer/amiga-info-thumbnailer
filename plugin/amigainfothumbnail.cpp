#include <KIO/ThumbnailCreator>
#include <KPluginFactory>
#include <QImage>
#include <QProcess>
#include <QTemporaryFile>

class AmigaInfoCreator : public KIO::ThumbnailCreator
{
    Q_OBJECT
public:
    using KIO::ThumbnailCreator::ThumbnailCreator;
    KIO::ThumbnailResult create(const KIO::ThumbnailRequest &request) override;
};

KIO::ThumbnailResult AmigaInfoCreator::create(const KIO::ThumbnailRequest &request)
{
    const QString path = request.url().toLocalFile();

    QTemporaryFile tmpFile(QStringLiteral("amiga-info-thumb-XXXXXX.png"));
    if (!tmpFile.open()) {
        return KIO::ThumbnailResult::fail();
    }
    QString tmpPath = tmpFile.fileName();
    tmpFile.close();

    QProcess proc;
    proc.start(QStringLiteral("amiga-info-to-png"), {path, tmpPath});
    if (!proc.waitForFinished(10000) || proc.exitCode() != 0) {
        return KIO::ThumbnailResult::fail();
    }

    QImage img;
    if (!img.load(tmpPath, "PNG")) {
        return KIO::ThumbnailResult::fail();
    }

    return KIO::ThumbnailResult::pass(img);
}

K_PLUGIN_CLASS_WITH_JSON(AmigaInfoCreator, "amigainfothumbnail.json")

#include "amigainfothumbnail.moc"
