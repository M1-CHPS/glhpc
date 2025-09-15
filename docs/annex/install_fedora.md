# Installing Fedora (Step-by-Step Guide)

This guide explains how to install Fedora and set up the required tools for this course. Following these steps will give you an environment suitable for the entire Master’s program.

Note that dual booting is not covered in this guide.

## Requirements

To install Fedora, you will need to:

- Make a complete backup of all your data (Installation will **permanently** delete everything already on the computer.)
- Use a USB drive; around 10GB should be sufficient. **Note that the drive will be completely erased.**
- A working computer to write Fedora on USB.

## Downloading Fedora

First, go to [the Fedora website (fedoraproject.org)](https://fedoraproject.org/workstation/), then download and install the **Fedora Media Writer**. Make sure you have plugged in your USB stick, then follow these steps:

<figure markdown="span">
  <img src="../install_fedora/first_step.png" style="max-width:60%; width: auto;">
</figure>

---

## Fedora Version


<figure markdown="span">
  <img src="../install_fedora/second_step.png" style="max-width:60%; width: auto;">
</figure>

Here, I recommend choosing either Fedora Workstation or KDE Plasma Desktop:

- **Fedora Workstation** is the official GNOME version of Fedora: It is very stable and **lightweight**. The desktop is more akin to macOS.
- **KDE Plasma Desktop** is the official KDE Spin of Fedora. KDE is less stable and can be **very heavy**, but it is also more similar to Windows and its look-and-feel are easier to customize.

Note that you can switch between the two without reinstalling Fedora, although it requires some additional steps.

---

## Writing
<figure markdown="span">
  <img src="../install_fedora/third_step.png" style="max-width:60%; width: auto;">
</figure>

Here, you should make sure that:

- You select the correct hardware architecture for the target computer. It is most likely Intel/AMD 64-bit.
- Select your USB drive; here, `VendorCo` should be the name of your drive.

!!! Danger
  Remember that the USB drive will be completely erased when you press 'Download and Write'!

<figure markdown="span">
  <img src="../install_fedora/fourth_step.png" style="max-width:60%; width: auto;">
</figure>

Wait for the download to complete, then safely remove the USB stick and plug it into the computer on which you want to install Fedora.

!!! Danger
  Remember to back up your important files!

## Booting on Fedora

Now, you will need to boot from the Fedora drive to begin the installation. 
When you start your device, you should see something akin to **PRESS DEL OR F2 TO ENTER BIOS SETTING**. Press the corresponding key when you see this screen until your BIOS appears. You can restart your computer if necessary.

On some hardware, F12 or ESC may directly show a temporary boot menu.

<figure markdown="span">
  <img src="../install_fedora/fifth_step.png" style="max-width:60%; width: auto;">
</figure>


You should see something *similar* to this. Note that it may look very different, as this menu is hardware dependent.

You should look for something named **Boot Priorities** or **Boot Order**, and modify the boot order so that the **first item is either:**

- The name of your USB Drive
- OR Something like "Fedora Live Image"
- OR "Boot from USB"

Make sure to save the settings if necessary, then exit the BIOS. **Do not modify anything else in this menu unless you know what you are doing.**

## Installing Fedora

Now, your PC should reboot into Fedora. It is possible that a GRUB menu appears with multiple options; you should select the first one named "Install Fedora" or "Start Fedora Workstation Live".

<figure markdown="span">
  <img src="../install_fedora/sixth_step.png" style="max-width:60%; width: auto;">
</figure>

You should then select "Install Fedora to Hard Drive".

<figure markdown="span">
  <img src="../install_fedora/seventh_step.png" style="max-width:60%; width: auto;">
</figure>

Then:

- Select the language of your choice, although I recommend English (United States).
- Select the correct keyboard layout:
    - us for QWERTY
    - fr for AZERTY
- Click Next.

<figure markdown="span">
  <img src="../install_fedora/eighth_step.png" style="max-width:60%; width: auto;">
</figure>

Select the disk where you want to install Fedora, and make sure to select **Use entire disk**. Then click Next.

<figure markdown="span">
  <img src="../install_fedora/ninth_step.png" style="max-width:60%; width: auto;">
</figure>

We will skip encryption for this guide; simply click Next.

The next page will summarize the changes and ask you to confirm before starting the installation.
You may be asked to create a new user. Make sure to remember the password!

!!! Danger
  Make sure your device is plugged in if it is a laptop!

When the installation is finished, power off the device, **then** remove the USB drive, and then power it on.
**Do not unplug the USB drive while the installation is ongoing.**

Congratulations, Fedora is now installed! You can log in with the user account you created and begin installing the required course packages.
