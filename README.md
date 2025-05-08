A PowerShell-based system process monitor that provides real-time monitoring of system resources, processes, and network connections with an interactive interface.

## Features

- **Real-time Process Monitoring**
  - Top CPU-consuming processes
  - Top memory-consuming processes
  - Detailed process information
  - Process search functionality
  - Process tree view
  - Network connection monitoring

- **System Resource Monitoring**
  - CPU usage percentage
  - Memory usage (total, used, and percentage)
  - Real-time updates

- **Interactive Controls**
  - Process management
  - Customizable refresh rates
  - Detailed process information
  - Network connection details

## Requirements

- Windows PowerShell 5.1 or later
- Administrator privileges (for some features)

## Installation

1. Clone or download this repository
2. Open PowerShell as Administrator
3. Set the execution policy to allow script execution:
   ```powershell
   Set-ExecutionPolicy RemoteSigned
   ```

## Usage

Run the script:
```powershell
.\sysmon.ps1
```

### Controls

| Key | Function |
|-----|----------|
| `q` | Quit the application |
| `k` | Kill a process |
| `s` | Search for processes |
| `d` | Toggle process details view |
| `t` | Show process tree |
| `n` | Show network connections |
| `r` | Change refresh rate |
| `+` | Increase refresh rate |
| `-` | Decrease refresh rate |

### Features in Detail

#### Process Management
- View top CPU and memory-consuming processes
- Kill processes with confirmation
- Search processes by name
- View detailed process information including:
  - Process name and PID
  - CPU time
  - Memory usage
  - Thread count
  - Start time
  - Process path

#### System Resources
- Real-time CPU usage monitoring
- Memory usage statistics
- Resource utilization percentages

#### Network Monitoring
- View all established network connections
- See local and remote addresses
- Identify processes using network connections

#### Customization
- Adjustable refresh rate (1000-10000ms)
- Quick refresh rate adjustment with + and - keys
- Custom refresh rate setting

## Examples

### Viewing Process Details
1. Press `d` to toggle process details
2. Enter the PID when prompted
3. View comprehensive process information

### Searching for Processes
1. Press `s`
2. Enter process name or partial name
3. View matching processes

### Monitoring Network Connections
1. Press `n`
2. View all established network connections
3. See which processes are using network resources

### Adjusting Refresh Rate
1. Press `r` to set custom rate
2. Enter value between 1000-10000ms
3. Or use `+` and `-` for quick adjustments

## Notes

- Some features require administrator privileges
- Network connection monitoring may be limited by system security settings
- Process killing requires confirmation to prevent accidental termination

## License

This project is open source and available under the MIT License. 