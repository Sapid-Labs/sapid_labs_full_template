# Landing Page Release Playbook

## Assets

### Favicon

Use [favicon.io](https://favicon.io/) to generate or download favicon assets.

Paste the following code into the `head` tag of your html:

```html
<link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">
<link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
<link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">
<link rel="manifest" href="/site.webmanifest">
```

## Deployment on Firebase Hosting

```bash
firebase init hosting
```

In the Firebase Console, add a custom domain to your website. This will take a few seconds. Once finished, copy the value next to the TXT record type and paste that into NameCheap under the Advanced DNS tab.

For full instructions on hosting on NameCheap, follow the guide here: https://firebase.google.com/docs/hosting/custom-domain#dns-records-namecheap