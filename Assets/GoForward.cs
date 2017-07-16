using UnityEngine;
using System.Collections;

public class GoForward : MonoBehaviour {

    public float force = 5;
    Rigidbody rb;
    public float targetSpeed;
    public float currentSpeed;
    public bool hasTargetSpeed;

	// Use this for initialization
	void Start () {
         rb = GetComponent<Rigidbody>();
	}
	
	// Update is called once per frame
	void FixedUpdate () {
        currentSpeed = Vector3.Dot(gameObject.transform.right, rb.velocity);
        if (hasTargetSpeed)
        {
            rb.AddRelativeForce(force * (targetSpeed - currentSpeed) * Vector3.right);
        }
        else
        {
            rb.AddRelativeForce(force * Vector3.right);
        }
        
	}
}
