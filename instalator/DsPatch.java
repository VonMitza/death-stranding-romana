import java.nio.file.*;
import java.util.zip.*;
import java.io.*;
import java.lang.reflect.*;
public class DsPatch {
    public static void main(String[] a) throws Exception {
        Object app = Class.forName("com.shade.platform.model.app.ApplicationManager").getMethod("getApplication").invoke(null);
        Class<?> sm = Class.forName("com.shade.platform.model.ServiceManager");
        Object svc = sm.getConstructor(Path.class).newInstance(Files.createTempDirectory("dsro").resolve("config.json"));
        Field fld = app.getClass().getDeclaredField("serviceManager");
        fld.setAccessible(true);
        fld.set(app, svc);
        Class<?> pc = Class.forName("com.shade.decima.cli.converters.ProjectConverter");
        Object p = pc.getMethod("convert", String.class).invoke(pc.getConstructor().newInstance(), a[0]);
        Object m = Class.forName("com.shade.decima.model.app.Project").getMethod("getPackfileManager").invoke(p);
        Method find = Class.forName("com.shade.decima.model.packfile.PackfileManager").getMethod("findFile", String.class);
        Method read = Class.forName("com.shade.decima.model.archive.ArchiveFile").getMethod("readAllBytes");
        int ok = 0, bad = 0;
        try (DataInputStream in = new DataInputStream(new BufferedInputStream(new GZIPInputStream(Files.newInputStream(Path.of(a[1]))), 1 << 20))) {
            byte[] mg = new byte[8]; in.readFully(mg);
            if (!new String(mg, "ASCII").equals("DSROPAT1")) throw new IOException("bad patch file");
            int n = in.readInt();
            for (int i = 0; i < n; i++) {
                byte[] pb = new byte[in.readUnsignedShort()]; in.readFully(pb);
                String path = new String(pb, "UTF-8");
                long crc = in.readInt() & 0xffffffffL;
                int nr = in.readInt();
                Object af = find.invoke(m, path);
                byte[] data = af == null ? null : (byte[]) read.invoke(af);
                boolean good = data != null;
                if (good) { CRC32 c = new CRC32(); c.update(data); good = c.getValue() == crc; }
                for (int r = 0; r < nr; r++) {
                    int off = in.readInt(), len = in.readInt();
                    if (good) in.readFully(data, off, len); else in.skipBytes(len);
                }
                if (good) {
                    Path out = Path.of(a[2]).resolve(path);
                    Files.createDirectories(out.getParent());
                    Files.write(out, data);
                    ok++;
                } else { bad++; System.out.println("SKIP " + path); }
            }
        }
        System.out.println("imagini ok=" + ok + " sarite=" + bad);
        System.exit(bad > 0 && ok == 0 ? 1 : 0);
    }
}
