import { useState } from "react";
import { getRooms, getReservations, createReservation, cancelReservation } from "./services/reservationService";

function App() {
  const [activePage, setActivePage] = useState("Dashboard");
  const [isLoggedIn, setIsLoggedIn] = useState(false);

  const [roomData] = useState(getRooms());
  const [reservations, setReservations] = useState(getReservations());

  const handleCreateReservation = () => {
  const newReservation = createReservation({
    room: "Meeting Room A",
    roomId: 1,
    userName: "Demo User",
    date: "2026-05-01",
    time: "12:00 - 13:00",
    purpose: "New Meeting",
  });

  setReservations([...reservations, newReservation]);
  setActivePage("My Reservations");
};

const handleCancel = (id) => {
  const updated = cancelReservation(id, reservations);
  setReservations(updated);
};
const totalReservations = reservations.length;

const cancelledCount = reservations.filter(r => r.status === "Cancelled").length;

const activeCount = reservations.filter(r => r.status === "Confirmed").length;

const usageRate = roomData.length > 0
  ? Math.round((activeCount / roomData.length) * 100)
  : 0;


  return isLoggedIn ? (
    <div style={styles.page}>
      <aside style={styles.sidebar}>
        <h2 style={styles.logo}>RoomPanel</h2>

        <nav style={styles.nav}>
          {["Dashboard", "Rooms", "Calendar", "My Reservations"].map((item) => (
            <div
              key={item}
              onClick={() => setActivePage(item)}
              style={activePage === item ? styles.activeNav : styles.navItem}
            >
              {item}
            </div>
          ))}

          <div
            onClick={() => setIsLoggedIn(false)}
            style={styles.logout}
          >
            Logout
          </div>
        </nav>
      </aside>

          <main style={styles.main}>
            {activePage === "Dashboard" && (
              <Dashboard 
                 total={totalReservations}
                 usage={usageRate}
                 cancelled={cancelledCount}
              />
            )}
            {activePage === "Rooms" && <Rooms rooms={roomData} />}
            {activePage === "Calendar" && (
             <Calendar onCreateReservation={handleCreateReservation} />
            )}
            {activePage === "My Reservations" && (
              <MyReservations reservations={reservations} onCancel={handleCancel} />
            )}
          </main>
        </div>
      ): (
      <Login setIsLoggedIn={setIsLoggedIn} />
    );
    }

function Dashboard({ total, usage, cancelled }) {
  const stats = [
    { title: "Total Reservations", value: total, bg: "#E3F2FD" },
    { title: "Room Usage Rate", value: `${usage}%`, bg: "#E8F5E9" },
    { title: "Cancelled Reservations", value: cancelled, bg: "#FFEBEE" },
    { title: "Most Used Room", value: "Meeting Room A", bg: "#F3E5F5" },
  ];

  const usageData = [
    { room: "Room A", usage: 80 },
    { room: "Room B", usage: 60 },
    { room: "Study Room 1", usage: 40 },
  ];

  const todayReservations = [
    { time: "10:00", room: "Meeting Room A", status: "Confirmed" },
    { time: "11:00", room: "Meeting Room B", status: "Confirmed" },
    { time: "14:00", room: "Study Room 1", status: "Pending" },
  ];

  return (
    <>
      <PageHeader title="Dashboard" subtitle="Meeting Room Reservation Panel" />

      <section style={styles.cardsGrid}>
        {stats.map((item) => (
          <div key={item.title} style={{ ...styles.card, background: item.bg }}>
            <p style={styles.cardTitle}>{item.title}</p>
            <h2 style={styles.cardValue}>{item.value}</h2>
          </div>
        ))}
      </section>

      <section style={styles.bottomGrid}>
        <div style={styles.panel}>
          <h3 style={styles.panelTitle}>Room Usage Overview</h3>

          {usageData.map((item) => (
            <div key={item.room} style={styles.usageRow}>
              <div style={styles.usageText}>
                <span>{item.room}</span>
                <span>{item.usage}%</span>
              </div>

              <div style={styles.progressBg}>
                <div style={{ ...styles.progressFill, width: `${item.usage}%` }} />
              </div>
            </div>
          ))}
        </div>

        <div style={styles.panel}>
          <h3 style={styles.panelTitle}>Today’s Reservations</h3>

          {todayReservations.map((item, index) => (
            <div key={index} style={styles.reservationRow}>
              <span>{item.time}</span>
              <span>{item.room}</span>
              <span
                style={{
                  ...styles.status,
                  color: item.status === "Confirmed" ? "#16A34A" : "#F59E0B",
                }}
              >
                {item.status}
              </span>
            </div>
          ))}
        </div>
      </section>
    </>
  );
}

function Rooms({ rooms }) {
  return (
    <>
      <PageHeader title="Rooms" subtitle="Browse available meeting and study rooms" />

      <section style={styles.roomGrid}>
        {rooms.map((room) => (
          <div key={room.name} style={styles.roomCard}>
            <div style={styles.roomImage}>
              <span>🏢</span>
            </div>

            <div style={styles.roomContent}>
              <div style={styles.roomTop}>
                <h3 style={styles.roomTitle}>{room.name}</h3>
                <span style={statusBadge(room.status)}>{room.status}</span>
              </div>

              <p style={styles.roomInfo}>Capacity: {room.capacity} people</p>
              <p style={styles.roomInfo}>Equipment: {room.equipment}</p>

              <button
                style={{
                  ...styles.reserveButton,
                  opacity: room.status === "Available" ? 1 : 0.5,
                }}
              >
                {room.status === "Available" ? "Reserve" : "View"}
              </button>
            </div>
          </div>
        ))}
      </section>
    </>
  );
}

function Calendar({ onCreateReservation }) {
  const timeSlots = [
    { time: "09:00 - 10:00", status: "Available" },
    { time: "10:00 - 11:00", status: "Reserved" },
    { time: "11:00 - 12:00", status: "Available" },
    { time: "13:00 - 14:00", status: "Available" },
    { time: "14:00 - 15:00", status: "Reserved" },
    { time: "15:00 - 16:00", status: "Cleaning" },
  ];

  return (
    <>
      <PageHeader
        title="Calendar"
        subtitle="Select date and time for reservation"
      />

      <div style={styles.panel}>
        
        {/* ÜST SEÇİM ALANI */}
        <div style={{ display: "flex", gap: "20px", marginBottom: "20px" }}>
          
          <select style={styles.select}>
            <option>Meeting Room A</option>
            <option>Meeting Room B</option>
            <option>Study Room 1</option>
            <option>Seminar Room</option>
          </select>

          <input type="date" style={styles.select} />
        </div>

        {/* TIME SLOTS */}
        <div style={styles.slotGrid}>
          {timeSlots.map((slot, index) => (
            <div
              key={index}
              style={{
                ...styles.slot,
                background:
                  slot.status === "Available"
                    ? "#DCFCE7"
                    : slot.status === "Reserved"
                    ? "#FEE2E2"
                    : "#FEF3C7",
                color:
                  slot.status === "Available"
                    ? "#16A34A"
                    : slot.status === "Reserved"
                    ? "#DC2626"
                    : "#D97706",
              }}
            >
              {slot.time}
            </div>
          ))}
        </div>

      <button style={styles.reserveButton} onClick={onCreateReservation}>
        Create Reservation
      </button>
      </div>
    </>
  );
}

function MyReservations({ reservations, onCancel }) {

  return (
    <>
      <PageHeader
        title="My Reservations"
        subtitle="View and manage your reservations"
      />

      <div style={styles.panel}>
        <table style={styles.table}>
          <thead>
            <tr>
              <th style={styles.th}>Room</th>
              <th style={styles.th}>Date</th>
              <th style={styles.th}>Time</th>
              <th style={styles.th}>Purpose</th>
              <th style={styles.th}>Status</th>
              <th style={styles.th}>Action</th>
            </tr>
          </thead>

          <tbody>
            {reservations.map((item, index) => (
              <tr key={index}>
                <td style={styles.td}>{item.room}</td>
                <td style={styles.td}>{item.date}</td>
                <td style={styles.td}>{item.time}</td>
                <td style={styles.td}>{item.purpose}</td>
                <td style={styles.td}>
                  <span
                    style={{
                      ...styles.smallBadge,
                      background:
                        item.status === "Confirmed"
                        ? "#DCFCE7"
                        : item.status === "Cancelled"
                        ? "#FEE2E2"
                        : "#FEF3C7",

                      color:
                        item.status === "Confirmed"
                        ? "#16A34A"
                        : item.status === "Cancelled"
                        ? "#DC2626"
                        : "#D97706",
                    }}
                  >
                    {item.status}
                  </span>
                </td>
                <td style={styles.td}>
                  <button style={styles.cancelButton} onClick={() => onCancel(item.id)}>
                    Cancel
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </>
  );
}

function Login({ setIsLoggedIn }) {
  return (
    <div style={styles.loginPage}>
      <div style={styles.loginVisual}>
        <div style={styles.visualCard}>
          <div style={styles.visualIcon}>📅</div>
          <h1 style={styles.visualTitle}>RoomPanel</h1>
          <p style={styles.visualText}>
            Manage meeting rooms, reservations, and availability from one simple panel.
          </p>
        </div>
      </div>

      <div style={styles.loginFormArea}>
        <div style={styles.loginBox}>
          <h2 style={styles.loginTitle}>Welcome Back</h2>
          <p style={styles.loginSubtitle}>
            Sign in to continue to the reservation panel.
          </p>

          <label style={styles.label}>Email</label>
          <input
            placeholder="Enter your email"
            style={styles.input}
          />

          <label style={styles.label}>Password</label>
          <input
            type="password"
            placeholder="Enter your password"
            style={styles.input}
          />

          <div style={styles.loginOptions}>
            <label style={styles.rememberMe}>
              <input type="checkbox" />
              Remember me
            </label>

            <button style={styles.textButton}>
              Forgot password?
            </button>
          </div>

          <button
            style={styles.loginButton}
            onClick={() => setIsLoggedIn(true)}
          >
            Login
          </button>

          <p style={styles.registerText}>
            Don’t have an account?{" "}
            <button style={styles.textButton}>
              Create account
            </button>
          </p>
        </div>
      </div>
    </div>
  );
}

function Placeholder({ title }) {
  return (
    <>
      <PageHeader title={title} subtitle="This UI screen will be designed in the next step" />
      <div style={styles.panel}>
        <h3>{title} screen placeholder</h3>
        <p style={{ color: "#64748B" }}>
          This page is currently a static UI placeholder.
        </p>
      </div>
    </>
  );
}

function PageHeader({ title, subtitle }) {
  return (
    <header style={styles.header}>
      <h1 style={styles.title}>{title}</h1>
      <p style={styles.subtitle}>{subtitle}</p>
    </header>
  );
}

const statusBadge = (status) => {
  const colors = {
    Available: { bg: "#DCFCE7", color: "#16A34A" },
    Reserved: { bg: "#FEE2E2", color: "#DC2626" },
    Cleaning: { bg: "#FEF3C7", color: "#D97706" },
  };

  return {
    background: colors[status].bg,
    color: colors[status].color,
    padding: "6px 10px",
    borderRadius: "999px",
    fontSize: "13px",
    fontWeight: "700",
  };
};

const styles = {

  logout: {
  marginTop: "20px",
  padding: "12px 16px",
  color: "#F87171",
  borderTop: "1px solid #334155",
  cursor: "pointer",
  fontWeight: "700",
},

  loginPage: {
  height: "100vh",
  display: "grid",
  gridTemplateColumns: "1fr 1fr",
  background: "#F8FAFC",
},

loginVisual: {
  background: "linear-gradient(135deg, #DBEAFE, #EEF2FF)",
  display: "flex",
  alignItems: "center",
  justifyContent: "center",
  padding: "40px",
},

visualCard: {
  maxWidth: "420px",
  textAlign: "center",
},

visualIcon: {
  width: "86px",
  height: "86px",
  margin: "0 auto 22px",
  borderRadius: "24px",
  background: "white",
  display: "flex",
  alignItems: "center",
  justifyContent: "center",
  fontSize: "40px",
  boxShadow: "0 12px 30px rgba(59, 130, 246, 0.18)",
},

visualTitle: {
  margin: 0,
  fontSize: "38px",
  color: "#0F172A",
},

visualText: {
  marginTop: "14px",
  color: "#475569",
  fontSize: "17px",
  lineHeight: "1.6",
},

loginFormArea: {
  display: "flex",
  alignItems: "center",
  justifyContent: "center",
  padding: "40px",
},

loginBox: {
  width: "390px",
  background: "white",
  padding: "34px",
  borderRadius: "22px",
  boxShadow: "0 16px 40px rgba(15, 23, 42, 0.1)",
  display: "flex",
  flexDirection: "column",
},

loginTitle: {
  margin: 0,
  fontSize: "30px",
  color: "#0F172A",
},

loginSubtitle: {
  marginTop: "8px",
  marginBottom: "24px",
  color: "#64748B",
},

label: {
  marginBottom: "7px",
  color: "#334155",
  fontSize: "14px",
  fontWeight: "700",
},

input: {
  padding: "13px 14px",
  borderRadius: "12px",
  border: "1px solid #CBD5E1",
  marginBottom: "16px",
  outline: "none",
  fontSize: "14px",
},

loginOptions: {
  display: "flex",
  alignItems: "center",
  justifyContent: "space-between",
  marginBottom: "18px",
},

rememberMe: {
  display: "flex",
  alignItems: "center",
  gap: "8px",
  color: "#64748B",
  fontSize: "14px",
},

textButton: {
  border: "none",
  background: "transparent",
  color: "#3B82F6",
  fontWeight: "700",
  cursor: "pointer",
  padding: 0,
},

loginButton: {
  padding: "13px",
  borderRadius: "12px",
  border: "none",
  background: "#3B82F6",
  color: "white",
  fontWeight: "800",
  cursor: "pointer",
  fontSize: "15px",
},

registerText: {
  marginTop: "20px",
  marginBottom: 0,
  textAlign: "center",
  color: "#64748B",
  fontSize: "14px",
},

  table: {
  width: "100%",
  borderCollapse: "collapse",
},

th: {
  textAlign: "left",
  padding: "14px",
  color: "#64748B",
  borderBottom: "1px solid #E2E8F0",
},

td: {
  padding: "16px 14px",
  borderBottom: "1px solid #E2E8F0",
  color: "#334155",
},

smallBadge: {
  padding: "6px 10px",
  borderRadius: "999px",
  fontWeight: "700",
  fontSize: "13px",
},

cancelButton: {
  border: "1px solid #FCA5A5",
  background: "#FFFFFF",
  color: "#DC2626",
  padding: "8px 12px",
  borderRadius: "8px",
  fontWeight: "700",
  cursor: "pointer",
},

  select: {
  padding: "12px",
  borderRadius: "10px",
  border: "1px solid #E2E8F0",
  minWidth: "200px",
},

slotGrid: {
  display: "grid",
  gridTemplateColumns: "repeat(3, 1fr)",
  gap: "16px",
  marginTop: "20px",
},

slot: {
  padding: "16px",
  borderRadius: "12px",
  textAlign: "center",
  fontWeight: "600",
  cursor: "pointer",
},

  page: {
    display: "flex",
    minHeight: "100vh",
    width: "100%",
    background: "#F8FAFC",
  },

  sidebar: {
    width: "240px",
    minHeight: "100vh",
    background: "#1E293B",
    color: "white",
    padding: "28px 22px",
  },

  logo: {
    margin: "0 0 36px 0",
    fontSize: "26px",
  },

  nav: {
    display: "flex",
    flexDirection: "column",
    gap: "12px",
  },

  activeNav: {
    background: "#3B82F6",
    padding: "12px 16px",
    borderRadius: "10px",
    fontWeight: "600",
    cursor: "pointer",
  },

  navItem: {
    padding: "12px 16px",
    color: "#CBD5E1",
    cursor: "pointer",
  },

  main: {
    flex: 1,
    padding: "36px",
    overflow: "auto",
  },

  header: {
    marginBottom: "28px",
  },

  title: {
    margin: 0,
    fontSize: "34px",
    color: "#0F172A",
  },

  subtitle: {
    marginTop: "6px",
    color: "#64748B",
    fontSize: "16px",
  },

  cardsGrid: {
    display: "grid",
    gridTemplateColumns: "repeat(4, minmax(0, 1fr))",
    gap: "20px",
  },

  card: {
    minHeight: "130px",
    padding: "22px",
    borderRadius: "18px",
    boxShadow: "0 10px 25px rgba(15, 23, 42, 0.08)",
  },

  cardTitle: {
    margin: 0,
    color: "#64748B",
    fontSize: "15px",
  },

  cardValue: {
    marginTop: "12px",
    marginBottom: 0,
    fontSize: "28px",
    color: "#0F172A",
  },

  bottomGrid: {
    display: "grid",
    gridTemplateColumns: "1fr 1fr",
    gap: "24px",
    marginTop: "30px",
  },

  panel: {
    background: "white",
    padding: "26px",
    borderRadius: "18px",
    boxShadow: "0 10px 25px rgba(15, 23, 42, 0.08)",
  },

  panelTitle: {
    marginTop: 0,
    marginBottom: "26px",
    fontSize: "22px",
    color: "#334155",
  },

  usageRow: {
    marginBottom: "22px",
  },

  usageText: {
    display: "flex",
    justifyContent: "space-between",
    marginBottom: "8px",
    color: "#475569",
  },

  progressBg: {
    height: "12px",
    background: "#E2E8F0",
    borderRadius: "999px",
  },

  progressFill: {
    height: "12px",
    background: "#3B82F6",
    borderRadius: "999px",
  },

  reservationRow: {
    display: "grid",
    gridTemplateColumns: "80px 1fr 110px",
    alignItems: "center",
    padding: "14px 0",
    borderBottom: "1px solid #E2E8F0",
    color: "#475569",
  },

  status: {
    fontWeight: "700",
    textAlign: "right",
  },

  roomGrid: {
    display: "grid",
    gridTemplateColumns: "repeat(2, minmax(0, 1fr))",
    gap: "24px",
  },

  roomCard: {
    background: "white",
    borderRadius: "18px",
    overflow: "hidden",
    boxShadow: "0 10px 25px rgba(15, 23, 42, 0.08)",
  },

  roomImage: {
    height: "120px",
    background: "linear-gradient(135deg, #DBEAFE, #EEF2FF)",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    fontSize: "42px",
  },

  roomContent: {
    padding: "22px",
  },

  roomTop: {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    gap: "16px",
  },

  roomTitle: {
    margin: 0,
    color: "#0F172A",
  },

  roomInfo: {
    color: "#64748B",
    margin: "10px 0",
  },

  reserveButton: {
    marginTop: "14px",
    width: "100%",
    border: "none",
    background: "#3B82F6",
    color: "white",
    padding: "12px",
    borderRadius: "10px",
    fontWeight: "700",
    cursor: "pointer",
  },
};

export default App;
